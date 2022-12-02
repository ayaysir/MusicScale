//
//  FileUtil.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/12/03.
//

import Foundation
import CodableCSV

struct FileUtil {
    
    /// 임시 파일 링크 생성
    /// https://stackoverflow.com/questions/19959642/uiactivityviewcontroller-with-alternate-filename
    static func createLinkToFile(atURL fileURL: URL, withName fileName: String) -> URL? {
        let fileManager = FileManager.default
        // get the temp directory
        let tempDirectoryURL = fileManager.temporaryDirectory
        // and append the new file name
        let linkURL = tempDirectoryURL.appendingPathComponent(fileName)
        
        do {
            // there is already a hard link with that name
            if fileManager.fileExists(atPath: linkURL.path) {
                try fileManager.removeItem(at: linkURL)     // get rid of it
            }
            
            // create the hard link
            try fileManager.linkItem(at: fileURL, to: linkURL)
            
            return linkURL
        } catch let error as NSError {
            print("\(error)")
            return nil
        }
    }
    
    static func createTempCSVFile<T: Codable>(fileName: String, codableList list: [T], headers: [String]) throws -> URL {
        
        let fm = FileManager.default
        let cacheURL = fm.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(fileName).csv")
        
        let encoder = CSVEncoder() {
            $0.headers = headers
            $0.dateStrategy = .iso8601
        }
        
        let data = try encoder.encode(list, into: Data.self)
        try data.write(to: cacheURL)
        
        return cacheURL
    }
}
