//
//  ProgressCircle.swift
//  ReadRate
//
//  Created by Evan Freeze on 1/27/21.
//  Copyright © 2021 Evan Freeze. All rights reserved.
//

import SwiftUI

struct ProgressCircle<T: View>: View {
    let progress: Double
    let progressColor: Color
    let centerContent: T
    
    let circleProgressSize: CGFloat = 52.0
    let circleLineWidth: CGFloat = 6.0
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: circleLineWidth)
                .opacity(0.1)
                .foregroundColor(progressColor)
                .frame(width: circleProgressSize, height: circleProgressSize)
            Circle()
                .trim(from: 0.0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(lineWidth: circleLineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(progressColor)
                .frame(width: circleProgressSize, height: circleProgressSize)
                .rotationEffect(Angle(degrees: 270.0))
            centerContent
        }
    }
}

struct ProgressCircle_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCircle(
            progress: bookOne.progressBarFillAmount,
            progressColor: .blue,
            centerContent: bookOne.progressIcon
        )
    }
}
