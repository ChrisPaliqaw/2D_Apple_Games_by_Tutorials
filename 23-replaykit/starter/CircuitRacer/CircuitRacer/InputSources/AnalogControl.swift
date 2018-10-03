/**
 * Copyright (c) 2017 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
 * distribute, sublicense, create a derivative work, and/or sell copies of the
 * Software in any work that is designed, intended, or marketed for pedagogical or
 * instructional purposes related to programming, coding, application development,
 * or information technology.  Permission for such use, copying, modification,
 * merger, publication, distribution, sublicensing, creation of derivative works,
 * or sale is expressly withheld.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit

class AnalogControl: UIView {
  
  let baseCenter: CGPoint
  
  let knobImageView: UIImageView
  let baseImageView: UIImageView
  
  var knobImageName: String = "knob" {
    didSet {
      knobImageView.image = UIImage(named: knobImageName)
    }
  }
  
  var baseImageName: String = "base" {
    didSet {
      baseImageView.image = UIImage(named: baseImageName)
    }
  }
  
  var delegate: InputControlProtocol?
  
  override init(frame: CGRect) {
    
    baseCenter = CGPoint(x: frame.size.width/2,
      y: frame.size.height/2)
    
    knobImageView = UIImageView(image:  UIImage(named: knobImageName))
    knobImageView.frame.size.width /= 2
    knobImageView.frame.size.height /= 2
    knobImageView.center = baseCenter
    
    baseImageView = UIImageView(image: UIImage(named: baseImageName))
    
    super.init(frame: frame)
    
    isUserInteractionEnabled = true
    
    baseImageView.frame = bounds
    addSubview(baseImageView)
    
    addSubview(knobImageView)
    
    assert(bounds.contains(knobImageView.bounds),
      "Analog control should be larger than the knob in size")
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }
  
  func updateKnobWithPosition(position: CGPoint) {

    var positionToCenter = position - baseCenter
    var direction: CGPoint
    
    if positionToCenter == CGPoint.zero {
      direction = CGPoint.zero
    } else {
      direction = positionToCenter.normalized()
    }
    

    let radius = frame.size.width/2
    var length = positionToCenter.length()
    

    if length > radius {
      length = radius
      positionToCenter = direction * radius
    }
    
    let relPosition = CGPoint(x: direction.x * (length/radius),
      y: direction.y * (length/radius) * -1)
    
    knobImageView.center = baseCenter + positionToCenter
    delegate?.directionChangedWithMagnitude(position: relPosition)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      let touchLocation = touch.location(in: self)
      updateKnobWithPosition(position: touchLocation)
    }
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let touch = touches.first {
      let touchLocation = touch.location(in: self)
      updateKnobWithPosition(position: touchLocation)
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    updateKnobWithPosition(position: baseCenter)
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
    updateKnobWithPosition(position: baseCenter)
  }
}
