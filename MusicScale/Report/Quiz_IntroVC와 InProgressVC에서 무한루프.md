<!---
  Quiz_IntroVC와 InProgressVC에서 무한루프.md
  MusicScale

  Created by yoonbumtae on 2022/06/11.
  
-->

## Conditions

- 문제를 전부 풀고 isAllQuestionFinished = true가 되는 상황에서
- QuizFinishedVC에서 DequeReusableCell에 클래스 이름이 제대로 지정되어 있지 않을 떄 오류가 발생하면서 해당 VC에 크래시 발생
- 이 상태에서 앱을 재실행하고 Quiz_IntroVC를 실행하면 InProgressVC와 무한루프하는 문제 발생

## Causes

```swift title="QuizIntroTableViewController.swift"
        if quizStore.savedLeitnerSystem != nil {
            let inProgressVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuizInProgressViewController") as! QuizInProgressViewController
            inProgressVC.quizViewModel = quizViewModel
            inProgressVC.introVC = self
            navigationController?.setViewControllers([inProgressVC], animated: false)
            return
        }
```

```swift title="QuizInProgressViewController.swift"
        if quizViewModel.isAllQuestionFinished {
            navigationController?.setViewControllers([introVC], animated: false)
        }
```

- isAllQuestionFinished = true가 되었지만 크래시 발생으로 인해 savedLeitnerSystem이 nil이 되지 않은 채로 종료됨
- quizStore.savedLeitnerSystem가 살아있는 상태에서 IntoVC에서 inProgressVC로 이동하였는데 
- InProgressVC에서 isAllQuestionFinished = true인 상태이기 때문에 introVC(=IntroVC)로 다시 이동하는 상태이기 때문에
- 둘이 계속 반복되어 무한루프에 빠지는 증상 발생하였음

## Solutions

```swift title="QuizFinishedViewController.swift"
        if quizViewModel.isAllQuestionFinished {
            // 삭제
            // navigationController?.setViewControllers([introVC], animated: false)
            
            let finishedVC = initVCFromStoryboard(storyboardID: .QuizFinishedViewController) as! QuizFinishedViewController
            finishedVC.quizViewModel = quizViewModel
            navigationController?.setViewControllers([finishedVC], animated: false)
            return
        }
```

- QuizFinishedVC가 새로 마련됨에 따라 introVC 대신 퀴즈가 완료된 경우 QuizFinishedVC로 리다이렉트 되도록 하여 문제 해결하였음
- 이 상태에서 QuizFinishedVC의 크래시 조건이 유지되더라도 무한루프는 발생하지 않음
