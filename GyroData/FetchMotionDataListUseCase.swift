//
//  FetchMotionDataListUseCase.swift
//  GyroData
//
//  Created by 천수현 on 2022/12/28.
//

import Foundation

final class FetchMotionDataListUseCase {
    private let motionDataListStorage: MotionDataListStorageProtocol

    init(motionDataListStorage: MotionDataListStorageProtocol) {
        self.motionDataListStorage = motionDataListStorage
    }

    func execute(page: Int, completion: @escaping (Result<[MotionRecord], Error>) -> Void) {
        motionDataListStorage.loadMotionRecords(page: page) { result in
            switch result {
            case .success(let records):
                completion(.success(records))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}