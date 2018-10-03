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

import Foundation
import GameKit

class AchievementsHelper {
  
  static let MaxCollisions = 20.0
  static let DestructionHeroAchievementId =
    "com.razeware.CircuitRacer.destructionhero"
  static let AmateurAchievementId =
    "com.razeware.CircuitRacer.amateurracer"
  static let IntermediateAchievementId =
    "com.razeware.CircuitRacer.intermediateracer"
  static let ProfessionalHeroAchievementId =
    "com.razeware.CircuitRacer.professionalracer"
  
  class func collisionAchievement(noOfCollisions: Int)
    -> GKAchievement {
      //1
      let percent =
        Double(noOfCollisions)/AchievementsHelper.MaxCollisions
          * 100
      
      //2
      let collisionAchievement = GKAchievement(
        identifier: AchievementsHelper.DestructionHeroAchievementId)
      
      //3
      collisionAchievement.percentComplete = percent
      collisionAchievement.showsCompletionBanner = true
      return collisionAchievement
  }
  
  class func achievementForLevel(levelType: LevelType) -> GKAchievement {
    var achievementId = AchievementsHelper.AmateurAchievementId
    
    if levelType == .medium {
      achievementId = AchievementsHelper.IntermediateAchievementId
    } else if levelType == .hard {
      achievementId = AchievementsHelper.ProfessionalHeroAchievementId
    }
    
    let levelAchievement = GKAchievement(identifier: achievementId)
    
    levelAchievement.percentComplete = 100
    levelAchievement.showsCompletionBanner = true
    
    return levelAchievement
  }
  
  // MARK: Achievements Challenge-1
  static let MaxPlays = 10.0
  static let RacingAddictAchievementId = "com.razeware.CircuitRacer.racingaddict"
  
  class func racingAddictAchievement(noOfPlays: Int) -> GKAchievement {
    //1
    let percent = Double(noOfPlays)/AchievementsHelper.MaxPlays * 100
    
    //2
    let racingAddictAchievement = GKAchievement(identifier: AchievementsHelper.RacingAddictAchievementId)
    
    //3
    racingAddictAchievement.percentComplete = percent
    racingAddictAchievement.showsCompletionBanner = true
    
    return racingAddictAchievement
  }
}

