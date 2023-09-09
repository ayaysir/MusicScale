//
//  ScaleComparisonViewModel.swift
//  MusicScale
//
//  Created by yoonbumtae on 2022/12/05.
//

import Foundation

class ScaleComparisonViewModel {
    
    private var totalCompareList: [ScaleInfoViewModel] = []
    private(set) var firstScaleInfoVM: ScaleInfoViewModel
    
    init(firstScaleInfoVM: ScaleInfoViewModel) {
        self.firstScaleInfoVM = firstScaleInfoVM
    }
    
    func append(viewModel: ScaleInfoViewModel) {
        totalCompareList.append(viewModel)
    }
    
    func remove(viewModel: ScaleInfoViewModel) {
        totalCompareList = totalCompareList.filter { $0.id != viewModel.id }
    }
    
    func contain(viewModel: ScaleInfoViewModel) -> Bool {
        return totalCompareList.contains { $0.id == viewModel.id }
    }
    
    func isFirstVM(viewModel: ScaleInfoViewModel) -> Bool {
        return viewModel.id == firstScaleInfoVM.id
    }
    
    var isComparisonAllowed: Bool {
        return totalCompareList.count > 0
    }
    
    var totalSegmentVMs: [ScaleInfoViewModel] {
        return [firstScaleInfoVM] + totalCompareList
    }
    
    var totalSegmentVMsName: [String] {
        return totalSegmentVMs.map { $0.name }
    }
    
    func printTotalSegmentVmsName() {
        totalSegmentVMs.forEach { print($0.name) }
        print("=========")
    }
}
