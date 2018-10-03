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

class GameScene: SKScene {
  override func didMove(to view: SKView) {
    backgroundColor = SKColor.black
    let starTexture = SKTexture(imageNamed: "spark.png")
    let emitter = SKEmitterNode()
    
    emitter.particleTexture = starTexture
    emitter.particleBirthRate = 20
    emitter.particleLifetime = 30.0
    emitter.emissionAngle = CGFloat(90.0).degreesToRadians()
    emitter.emissionAngleRange = CGFloat(360.0).degreesToRadians()
    emitter.particleSpeed = 50
    emitter.particleAlpha = 0.0
    emitter.particleAlphaSpeed = 0.5
    emitter.particleScale = 0.02
    emitter.particleScaleRange = 0.2
    emitter.particleScaleSpeed = 0.02
    emitter.particleColorBlendFactor = 1.0
    emitter.particleColor = SKColor.white
    emitter.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
    //emitter.advanceSimulationTime(15)
        
    addChild(emitter)
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    /* Called when a touch begins */
  }
  
  override func update(_ currentTime: TimeInterval) {
    /* Called before each frame is rendered */
  }
}
