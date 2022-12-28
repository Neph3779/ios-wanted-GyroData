//
//  MotionRecordingViewModel.swift
//  GyroData
//
//  Created by YunYoungseo on 2022/12/28.
//

import Foundation
import CoreMotion

final class MotionRecordingViewModel {
    var motionMode: MotionMode {
        didSet {
            coordinates.removeAll()
        }
    }
    private let timeOut = TimeInterval(60)
    private var startDate = Date()
    private var motionManager = CMMotionManager()
    private var coordinates = [Coordiante]()
    private var updateTimeInterval: TimeInterval {
        didSet {
            motionManager.accelerometerUpdateInterval = updateTimeInterval
            motionManager.gyroUpdateInterval = updateTimeInterval
        }
    }
    private var updateCompletion: (Coordiante) -> Void

    init(msInterval: Int, motionMode: MotionMode, updateCompletion: @escaping (Coordiante) -> Void) {
        self.motionMode = motionMode
        updateTimeInterval = Double(msInterval) / 1000
        self.updateCompletion = updateCompletion
    }

    // TODO: Error 처리하기
    func startRecording() {
        let updateHandler: (Coordiante) -> Void = { [weak self] newData in
            guard let self = self else { return }
            var isFullDatas: Bool {
                let maximumCount = Int(self.timeOut / self.updateTimeInterval)
                return self.coordinates.count >= maximumCount
            }

            if isFullDatas {
                self.coordinates.removeAll()
            }
            self.coordinates.append(newData)
            self.updateCompletion(newData)
            guard !isFullDatas else {
                self.stopRecording()
                return
            }
        }

        startDate = Date()
        switch motionMode {
        case .accelerometer:
            let accelerometerHandler: CMAccelerometerHandler = { [weak self] newData, error in
                guard let newData = newData?.acceleration else {
                    self?.stopRecording()
                    return
                }
                let newCoordinate = Coordiante(newData)
                updateHandler(newCoordinate)
            }
            motionManager.startAccelerometerUpdates(to: OperationQueue(), withHandler: accelerometerHandler)
        case .gyroscope:
            let gyroHandler: CMGyroHandler = { [weak self] newData, error in
                guard let newData = newData?.rotationRate else {
                    self?.stopRecording()
                    return
                }
                let newCoordinate = Coordiante(newData)
                updateHandler(newCoordinate)
            }
            motionManager.startGyroUpdates(to: OperationQueue(), withHandler: gyroHandler)
        }
    }

    func stopRecording() {
        motionManager.stopAccelerometerUpdates()
        motionManager.stopGyroUpdates()
    }
}

private extension Coordiante {
    init(_ data: CMAcceleration) {
        self.x = data.x
        self.y = data.y
        self.z = data.z
    }

    init(_ data: CMRotationRate) {
        self.x = data.x
        self.y = data.y
        self.z = data.z
    }
}