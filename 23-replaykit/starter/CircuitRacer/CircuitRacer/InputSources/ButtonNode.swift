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

import SpriteKit

protocol ButtonNodeResponder {
  func buttonPressed(button: ButtonNode)
}

enum ButtonIdentifier: String {
  case resume = "resume"
  case cancel = "cancel"
  case replay = "replay"
  case pause  = "pause"
  
  static let allIdentifiers: [ButtonIdentifier] = [.resume, .cancel, .replay, .pause]
  
  var selectedTextureName: String? {
    switch self {
      default:
        return nil
    }
  }
}

class ButtonNode: SKSpriteNode {
  
  var defaultTexture: SKTexture?
  var selectedTexture: SKTexture?
  
  var buttonIdentifier: ButtonIdentifier!
  
  var responder: ButtonNodeResponder {
    guard let responder = scene as? ButtonNodeResponder else {
      fatalError("ButtonNode may only be used within a 'ButtonNodeResponder' scene")
    }
    return responder
  }
  
  var isHighlighted = false {
    didSet {
      colorBlendFactor = isHighlighted ? 1.0 : 0.0
    }
  }
  
  var isSelected = false {
    didSet {
      texture = isSelected ? selectedTexture : defaultTexture
    }
  }
  
  init(templateNode: SKSpriteNode) {
    super.init(texture: templateNode.texture, color: SKColor.clear, size: templateNode.size)
    
    guard let nodeName = templateNode.name, let buttonIdentifier = ButtonIdentifier(rawValue: nodeName) else {
      fatalError("Unsupported button name found")
    }
    
    self.buttonIdentifier = buttonIdentifier
    
    name = templateNode.name
    position = templateNode.position
    
    //zPosition
    
    color = SKColor(white: 0.8, alpha: 1.0)
    
    defaultTexture = texture
    
    if let textureName = buttonIdentifier.selectedTextureName {
      selectedTexture = SKTexture(imageNamed: textureName)
    } else {
      selectedTexture = texture
    }
    
    for child in templateNode.children {
      addChild(child.copy() as! SKNode)
    }
    
    isUserInteractionEnabled = true
  }

  required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }
  
  func buttonTriggered() {
    if isUserInteractionEnabled {
      responder.buttonPressed(button: self)
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    if hasTouchWithinButton(touches: touches) {
      isHighlighted = true
    }
  }
  
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    isHighlighted = false
    
    if hasTouchWithinButton(touches: touches) {
      responder.buttonPressed(button: self)
    }
  }
  
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesCancelled(touches, with: event)
    
    isHighlighted = false
  }
  
  private func hasTouchWithinButton(touches: Set<UITouch>) -> Bool {
    guard let scene = scene else {fatalError("Button must be used within a scene")}
    
    let touchesInButton = touches.filter { touch in
      let touchPoint = touch.location(in: scene)
      let touchedNode = scene.atPoint(touchPoint)
      return touchedNode === self || touchedNode.inParentHierarchy(self)
    }
    return !touchesInButton.isEmpty
  }
  
  // MARK: Convenience
  static func parseButtonInNode(containerNode: SKNode) {
    for identifier in ButtonIdentifier.allIdentifiers {
      
      guard let templateNode = containerNode.childNode(withName: identifier.rawValue) as? SKSpriteNode else { continue }
      
      let buttonNode = ButtonNode(templateNode: templateNode)
      buttonNode.zPosition = templateNode.zPosition
      
      containerNode.addChild(buttonNode)
      templateNode.removeFromParent()
    }
  }
}
