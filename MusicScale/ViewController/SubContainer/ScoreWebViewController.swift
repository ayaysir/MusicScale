//
//  ScaleDetailWebViewController.swift
//  MusicScale
//
//  Created by yoonbumtae on 2021/12/16.
//

import UIKit
import WebKit

protocol ScoreWebVCDelegate: AnyObject {
  func didStartButtonClicked(_ controller: ScoreWebViewController)
  func didStopButtonClicked(_ controller: ScoreWebViewController)
}

protocol ScoreWebInjection {
  
  /**
   웹 악보에서 커서 움직이기 시작할 때
   예) webView.evaluateJavaScript("startTimer()")
   */
  func startTimer()
  
  /**
   웹 악보에서 커서 멈출 때
   예) webView.evaluateJavaScript("stopTimer()")
   */
  func stopTimer()
  
  /**
   wkView에 Abcjs 텍스트를 injection 한다.
   - parameter from: abcjs Text (캐릭터 충돌 문제해결된 것으로)
   - parameter needReload: 외부 컨트롤러에서 재실행을 하는거라면 **true**(기본값), 최초 실행이라면 **false**
   */
  func injectAbcjsText(from abcjsText: String, needReload: Bool, staffWidth: Int?)
}

class ScoreWebViewController: UIViewController {
  
  @IBOutlet weak var webView: WKWebView!
  
  weak var delegate: ScoreWebVCDelegate?
  
  var scaleInfoViewModel: ScaleInfoViewModel!
  var staffWidth: Int? = DEF_STAFFWIDTH
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadWebSheetPage()
  }
  
  func renderAbjcsText(needReload: Bool = false) {
    let abcjsText = ScaleInfoVCConfigStore.shared.degreesOrder == .ascending ? scaleInfoViewModel.abcjsTextAscending : scaleInfoViewModel.abcjsTextDescending
    injectAbcjsText(from: abcjsText, needReload: needReload, staffWidth: staffWidth)
  }
}

extension ScoreWebViewController: WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, ScoreWebInjection {
  
  func startTimer() {
    webView.evaluateJavaScript("startTimer()")
  }
  
  func stopTimer() {
    webView.evaluateJavaScript("stopTimer()")
  }
  
  func injectAbcjsText(from abcjsText: String, needReload: Bool = true, staffWidth: Int? = 460) {
    
    let abcjsTextFixed = charFixedAbcjsText(abcjsText)
    
    if needReload {
      stopTimer()
      webView.evaluateJavaScript(generateAbcJsInjectionSource(from: abcjsTextFixed, staffWidth: staffWidth))
    } else {
      let injectionSource = generateAbcJsInjectionSource(from: abcjsTextFixed, staffWidth: staffWidth)
      let injectionScript = WKUserScript(source: injectionSource, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
      webView.configuration.userContentController.addUserScript(injectionScript)
    }
    
  }
  
  func loadWebSheetPage() {
    
    if #available(iOS 14.0, *) {
      webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
    } else {
      // Fallback on earlier versions
      webView.configuration.preferences.javaScriptEnabled = true
    }
    
    // 웹 파일 로딩
    webView.uiDelegate = self
    webView.navigationDelegate = self
    let pageName = "index"
    guard let url = Bundle.main.url(forResource: pageName, withExtension: "html", subdirectory: "web") else {
      return
    }
    webView.loadFileURL(url, allowingReadAccessTo: url)
    webView.scrollView.isScrollEnabled = false
    
    // let abcjsText = ScaleInfoVCConfigStore.shared.degreesOrder == .ascending ? scaleInfoViewModel.abcjsTextAscending : scaleInfoViewModel.abcjsTextDescending
    // injectAbcjsText(from: abcjsText, needReload: false, staffWidth: staffWidth)
    renderAbjcsText()
    
    // 자바스크립트 -> 네이티브 앱 연결
    // 브리지 등록
    webView.configuration.userContentController.add(self, name: "notePlayback")
    
    // inject JS to capture console.log output and send to iOS
    let source = """
            function captureLog(msg) { window.webkit.messageHandlers.logHandler.postMessage(msg); }
            window.console.log = captureLog;
        """
    let script = WKUserScript(source: source, injectionTime: .atDocumentStart, forMainFrameOnly: false)
    webView.configuration.userContentController.addUserScript(script)
    // register the bridge script that listens for the output
    webView.configuration.userContentController.add(self, name: "logHandler")
    
  }
  
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    // print(#function, message.name)
    switch message.name {
      // ... //
    case "logHandler":
      print("console log:", message.body)
    case "notePlayback":
      let status = message.body as! String
      if let delegate = delegate {
        if status == "play" {
          delegate.didStartButtonClicked(self)
        } else if status == "stop" {
          delegate.didStopButtonClicked(self)
        }
      }
    default:
      break
    }
  }
}

// MARK: - 무음 모드에서도 소리 나오게 하기
extension ScoreWebViewController {
  
  // How to force WKWebView to ignore hardware silent switch on iOS?
  // https://stackoverflow.com/questions/56460362
  func initIgnoreSilenceMode() {
    
    NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(willResignActive), name: UIApplication.willResignActiveNotification, object: nil)
    
    webView.configuration.allowsInlineMediaPlayback = true
    webView.configuration.mediaTypesRequiringUserActionForPlayback = []
  }
  
  @objc func willResignActive() {
    disableIgnoreSilentSwitch(webView)
  }
  
  @objc func didBecomeActive() {
    //Always creates new js Audio object to ensure the audio session behaves correctly
    forceIgnoreSilentHardwareSwitch(webView, initialSetup: false)
  }
  
  private func disableIgnoreSilentSwitch(_ webView: WKWebView) {
    //Nullifying the js Audio object src is critical to restore the audio sound session to consistent state for app background/foreground cycle
    let jsInject = "document.getElementById('wkwebviewAudio').muted=true;"
    webView.evaluateJavaScript(jsInject, completionHandler: nil)
  }
  
  private func forceIgnoreSilentHardwareSwitch(_ webView: WKWebView, initialSetup: Bool) {
    //after some trial and error this seems to be minimal silence sound that still plays
    let silenceMono56kbps100msBase64Mp3 = "data:audio/mp3;base64,//tAxAAAAAAAAAAAAAAAAAAAAAAASW5mbwAAAA8AAAAFAAAESAAzMzMzMzMzMzMzMzMzMzMzMzMzZmZmZmZmZmZmZmZmZmZmZmZmZmaZmZmZmZmZmZmZmZmZmZmZmZmZmczMzMzMzMzMzMzMzMzMzMzMzMzM//////////////////////////8AAAA5TEFNRTMuMTAwAZYAAAAAAAAAABQ4JAMGQgAAOAAABEhNIZS0AAAAAAD/+0DEAAPH3Yz0AAR8CPqyIEABp6AxjG/4x/XiInE4lfQDFwIIRE+uBgZoW4RL0OLMDFn6E5v+/u5ehf76bu7/6bu5+gAiIQGAABQIUJ0QolFghEn/9PhZQpcUTpXMjo0OGzRCZXyKxoIQzB2KhCtGobpT9TRVj/3Pmfp+f8X7Pu1B04sTnc3s0XhOlXoGVCMNo9X//9/r6a10TZEY5DsxqvO7mO5qFvpFCmKIjhpSItGsUYcRO//7QsQRgEiljQIAgLFJAbIhNBCa+JmorCbOi5q9nVd2dKnusTMQg4MFUlD6DQ4OFijwGAijRMfLbHG4nLVTjydyPlJTj8pfPflf9/5GD950A5e+jsrmNZSjSirjs1R7hnkia8vr//l/7Nb+crvr9Ok5ZJOylUKRxf/P9Zn0j2P4pJYXyKkeuy5wUYtdmOu6uobEtFqhIJViLEKIjGxchGev/L3Y0O3bwrIOszTBAZ7Ih28EUaSOZf/7QsQfg8fpjQIADN0JHbGgQBAZ8T//y//t/7d/2+f5m7MdCeo/9tdkMtGLbt1tqnabRroO1Qfvh20yEbei8nfDXP7btW7f9/uO9tbe5IvHQbLlxpf3DkAk0ojYcv///5/u3/7PTfGjPEPUvt5D6f+/3Lea4lz4tc4TnM/mFPrmalWbboeNiNyeyr+vufttZuvrVrt/WYv3T74JFo8qEDiJqJrmDTs///v99xDku2xG02jjunrICP/7QsQtA8kpkQAAgNMA/7FgQAGnobgfghgqA+uXwWQ3XFmGimSbe2X3ksY//KzK1a2k6cnNWOPJnPWUsYbKqkh8RJzrVf///P///////4vyhLKHLrCb5nIrYIUss4cthigL1lQ1wwNAc6C1pf1TIKRSkt+a//z+yLVcwlXKSqeSuCVQFLng2h4AFAFgTkH+Z/8jTX/zr//zsJV/5f//5UX/0ZNCNCCaf5lTCTRkaEdhNP//n/KUjf/7QsQ5AEhdiwAAjN7I6jGddBCO+WGTQ1mXrYatSAgaykxBTUUzLjEwMKqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqg=="
    //Plays 100ms silence once the web page has loaded through HTML5 Audio element (through Javascript)
    //which as a side effect will switch WKWebView AudioSession to AVAudioSessionCategoryPlayback
    
    var jsInject: String
    if initialSetup {
      jsInject =
      "var s=new Audio('\(silenceMono56kbps100msBase64Mp3)');" +
      "s.id='wkwebviewAudio';" +
      "s.play();" +
      "s.loop=true;" +
      "document.body.appendChild(s);"
    } else {
      //Restore sound hack
      jsInject = "document.getElementById('wkwebviewAudio').muted=false;"
    }
    webView.evaluateJavaScript(jsInject, completionHandler: nil)
  }
  
  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    //As a result the WKWebView ignores the silent switch
    //        forceIgnoreSilentHardwareSwitch(webView, initialSetup: true)
  }
}
