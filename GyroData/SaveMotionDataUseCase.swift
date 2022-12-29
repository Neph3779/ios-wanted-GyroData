//
//  SaveMotionDataUseCase.swift
//  GyroData
//
//  Created by YunYoungseo on 2022/12/29.
//

final class SaveMotionDataUseCase {
    private let storage: MotionRecordingStorageProtocol

    init(storage: MotionRecordingStorageProtocol = MockMotionRecordingStorage()) {
        self.storage = storage
    }

    func excute(record: MotionRecord, completion: @escaping (Result<Void, Error>) -> Void) {
        storage.saveRecord(record: record) { result in
            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                print(error)
            }
        }
    }
}
