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
import SpriteKit

class GameViewController: UIViewController {

  var carType: CarType!
  var levelType: LevelType!
  
  var gameScene: GameScene!
  var analogControl: AnalogControl?
  
  override func viewDidLoad() {
    super.viewDidLoad()

    if let scene = GameScene(fileNamed:"GameScene") {
      
      gameScene = scene
      gameScene.gameSceneDelegate = self
      
      let skView = self.view as! SKView
      skView.showsFPS = true
      skView.showsNodeCount = true
      
      /* Sprite Kit applies additional optimizations to improve rendering performance */
      skView.ignoresSiblingOrder = true
      
      /* Set the scale mode to scale to fit the window */
      scene.scaleMode = .aspectFill
      scene.levelType = levelType
      scene.carType = carType
      
      skView.presentScene(scene)
      
      let analogControlSize: CGFloat = view.frame.size.height / 2.5
      let analogControlPadding: CGFloat = view.frame.size.height / 32
      
      analogControl = AnalogControl(frame: CGRect(origin: CGPoint(x: analogControlPadding, y: skView.frame.size.height - analogControlPadding - analogControlSize), size: CGSize(width: analogControlSize, height: analogControlSize)))
      analogControl?.delegate = scene
      view.addSubview(analogControl!)
    }
  }
}

extension GameViewController: GameSceneProtocol {
  func didSelectCancelButton(gameScene: GameScene) {
    _ = navigationController?.popToRootViewController(animated: false)
  }
  
  func didShowOverlay(gameScene: GameScene) {
    analogControl?.isHidden = true
  }
  
  func didDismissOverlay(gameScene: GameScene) {
    analogControl?.isHidden = false
  }
}
