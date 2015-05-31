
//
//  GameScene.swift
//  ZombieConga
//
//  Created by Tianda He on 5/14/15.
//  Copyright (c) 2015 Chris. All rights reserved.
//

import SpriteKit




class GameScene: SKScene {
    var lastUpdateTime: NSTimeInterval = 0
    var dt: NSTimeInterval = 0
    let zombieMovePointsPerSec: CGFloat = 480.0
    var velocity = CGPointZero
    var lastTouchLocation: CGPoint?
    let zombieRotateRadiansPerSec:CGFloat = 4.0 * π
    let catCollisionSound: SKAction = SKAction.playSoundFileNamed( "hitCat.wav", waitForCompletion: false)
    let enemyCollisionSound: SKAction = SKAction.playSoundFileNamed( "hitCatLady.wav", waitForCompletion: false)
    var zombieInvis = false
    let catSpeed:CGFloat = 480.0
    var lives = 20
    let backgroundMovePointsPerSec: CGFloat = 200.0
    var gameOver = false
    
    let zombie = SKSpriteNode(imageNamed: "zombie1")
    let playableRect: CGRect
    let zombieAnimation: SKAction
    let backgroundLayer = SKNode()
    let requirement = 3
    
    override init(size: CGSize) {
    let maxAspectRatio:CGFloat = 16.0/9.0 // 1
    let playableHeight = size.width / maxAspectRatio // 2
    let playableMargin = (size.height-playableHeight)/2.0
    playableRect = CGRect(x: 0, y: playableMargin,width: size.width, height: playableHeight) // 4 
        var textures:[SKTexture] = []
        for i in 1...4 {
            textures.append(SKTexture(imageNamed: "zombie\(i)")) }
        textures.append(textures[2])
        textures.append(textures[1])
        // 4
        zombieAnimation = SKAction.repeatActionForever( SKAction.animateWithTextures(textures, timePerFrame: 0.1))
        super.init(size: size) // 5
    }
    required init(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") // 6
    }
    
    func backgroundNode() -> SKSpriteNode {
        // 1
        backgroundLayer.zPosition = -1
        let backgroundNode = SKSpriteNode()
        backgroundNode.anchorPoint = CGPointZero
        backgroundNode.name = "background"
        // 2
        let background1 = SKSpriteNode(imageNamed: "background1")
        background1.anchorPoint = CGPointZero
        background1.position = CGPoint(x: 0, y: 0)
        backgroundNode.addChild(background1)
        let background2 = SKSpriteNode(imageNamed: "background2")
        background2.anchorPoint = CGPointZero
        background2.position =
        CGPoint(x: background1.size.width, y: 0)
        backgroundNode.addChild(background2)
        // 4
        backgroundNode.size = CGSize(
        width: background1.size.width + background2.size.width,
        height: background1.size.height)
        return backgroundNode
    }
    
    override func didMoveToView(view: SKView) {
        
            addChild(backgroundLayer)
        playBackgroundMusic("backgroundMusic.mp3")
        backgroundColor = SKColor.whiteColor()
        for i in 0...1 {
            let background = backgroundNode()
            background.anchorPoint = CGPointZero
            background.position =
            CGPoint(x: CGFloat(i)*background.size.width, y: 0)
            background.name = "background"
        
            backgroundLayer.addChild(background)
            }
//        let background = SKSpriteNode(imageNamed: "background1")
//        background.position = CGPoint(x: size.width/2, y: size.height/2)
//        background.zPosition = -1
//        background.zRotation = CGFloat(M_PI)/8
        
//        addChild(background)
        zombie.position = CGPoint (x:400, y:400)
//        zombie1.setScale(2.0)
        zombie.zPosition = 100

        backgroundLayer.addChild(zombie)
        var heartposi = CGPoint (x:100,y:1350)
        for i in 1...lives
        {
            heartposi.x += 50
            initheart(heartposi,index:i)
        }
    
        
        
        
        runAction(SKAction.repeatActionForever( SKAction.sequence([SKAction.runBlock(spawnEnemy),
            SKAction.waitForDuration(2.0)])))
        runAction(SKAction.repeatActionForever( SKAction.sequence([SKAction.runBlock(spawnCat),
            SKAction.waitForDuration(1.0)])))
//        debugDrawPlayableArea()
        
        
        }
    func moveBackground() {
                let backgroundVelocity =
                CGPoint(x: -self.backgroundMovePointsPerSec, y: 0)
                let amountToMove = backgroundVelocity * CGFloat(self.dt)
                backgroundLayer.position += amountToMove
                backgroundLayer.enumerateChildNodesWithName("background") { node, _ in
                    
                    
            let background = node as! SKSpriteNode
            let backgroundScreenPos = self.backgroundLayer.convertPoint(background.position, toNode:self)
                    
            if backgroundScreenPos.x <= -background.size.width { background.position = CGPoint(
            x: background.position.x + background.size.width*2,
            y: background.position.y)
            }
                }
    }
    func initheart(position:CGPoint,index:Int)
        {
        
        let heart = SKSpriteNode(imageNamed: "heart.png")
        heart.setScale(0.025)
        heart.name = "heart\(index)"
        heart.position = position
        addChild(heart)
        
    
        
    }
    func removeheart()
    {
        self.childNodeWithName("heart\(lives)")!.runAction(SKAction.removeFromParent())
    }
    
    
    func debugDrawPlayableArea() {
    let shape = SKShapeNode()
    let path = CGPathCreateMutable()
    CGPathAddRect(path, nil,playableRect)
    shape.path = path
    shape.strokeColor = SKColor.redColor()
    shape.lineWidth = 4.0
    addChild(shape)
    }
    
    override func update(currentTime: NSTimeInterval) {
            if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime} else
        { dt = 0}
            lastUpdateTime = currentTime
//            println("\(dt*1000) milliseconds since last update")
        if let lastTouch = lastTouchLocation {
            let diff = lastTouch - zombie.position
//            if diff.length() <= (zombieMovePointsPerSec * CGFloat(dt))
//            {
//                zombie.position = lastTouch
//                velocity = CGPointZero
//    stopZombieAnimation()
//            }
//            else
//            {
                moveSprite(zombie, velocity: velocity)
                rotateSprite(zombie, direction: velocity,zombieRotateRadiansPerSec: zombieRotateRadiansPerSec)
//            println("\(velocity)")
        
//            }
    
            boundsCheckZombie()
//            checkCollisions()
            moveTrain()
        
        moveBackground()
    if lives <= 0 && !gameOver
            { gameOver = true
        backgroundMusicPlayer.stop()
        let gameOverScene = GameOverScene(size: self.size, won: false)
        gameOverScene.scaleMode = self.scaleMode
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
        }
    }
    override func didEvaluateActions()
    { checkCollisions()
    }
    
    func startZombieAnimation() {
            if zombie.actionForKey("animation") == nil {
                zombie.runAction(SKAction.repeatActionForever(zombieAnimation),
                withKey: "animation") }
    }
    func stopZombieAnimation() { zombie.removeActionForKey("animation")
        
    }
                
                
    func moveSprite(sprite: SKSpriteNode, velocity: CGPoint)
    {
                // 1
                let amountToMove = velocity * CGFloat(dt)
//                println("Amount to move: \(amountToMove)")
                // 2
                sprite.position += amountToMove
    }
    
    func moveZombieToward(location: CGPoint) {
                    
                    startZombieAnimation()
                    let offset = location - zombie.position
                    let length = offset.length()
                    let direction = offset / length
                    velocity =  direction * zombieMovePointsPerSec
                
    }
    func blink()
    {
        let blinkTimes = 10.0
        let duration = 3.0
        let blinkAction = SKAction.customActionWithDuration(duration) {
        node, elapsedTime in
        let zombie = node as! SKSpriteNode
        let slice = duration / blinkTimes
        let remainder = Double(elapsedTime) % slice
        node.hidden = remainder > slice / 2
        }
        let Invistrue = SKAction.runBlock()
            {self.zombieInvis = true
//        println("true")
        }
        let group = SKAction.group([Invistrue, blinkAction])
        let Invisfalse = SKAction.runBlock()
            {self.zombieInvis = false
//        println("false")
        }
        zombie.runAction(SKAction.sequence([group, Invisfalse]))
    }
    
    func sceneTouched(touchLocation:CGPoint) {
        moveZombieToward(touchLocation)
        lastTouchLocation = touchLocation
        
    }
    func spawnCat() {
                        let cat = SKSpriteNode(imageNamed: "cat")
                        cat.name = "cat"
                        cat.position = backgroundLayer.convertPoint(CGPoint(
                         x: CGFloat.random(min: CGRectGetMinX(playableRect), max: CGRectGetMaxX(playableRect)),
                            y: CGFloat.random(min: CGRectGetMinY(playableRect), max: CGRectGetMaxY(playableRect))), fromNode:self)
                        cat.setScale(0)
                        backgroundLayer.addChild(cat)
                
                        let appear = SKAction.scaleTo(1.0, duration: 0.5)
                        cat.zRotation = -π / 16.0
                        let leftWiggle = SKAction.rotateByAngle(π/8.0, duration: 0.5)
                        let rightWiggle = leftWiggle.reversedAction()
                        let fullWiggle = SKAction.sequence([leftWiggle, rightWiggle])
                        let scaleUp = SKAction.scaleBy(1.2, duration: 0.25)
                        let scaleDown = scaleUp.reversedAction()
                        let fullScale = SKAction.sequence(
            [scaleUp, scaleDown, scaleUp, scaleDown])
                        let group = SKAction.group([fullScale, fullWiggle])
                        let groupWait = SKAction.repeatAction(group, count: 10)
                        let disappear = SKAction.scaleTo(0, duration: 0.5)
                        let removeFromParent = SKAction.removeFromParent()
                        let actions = [appear, groupWait, disappear, removeFromParent]
                        cat.runAction(SKAction.sequence(actions))
        
    }
    func boundsCheckZombie() {
        let bottomLeft = backgroundLayer.convertPoint(CGPoint(x: 0, y: CGRectGetMinY(playableRect)),fromNode:self)
        let topRight = backgroundLayer.convertPoint(CGPoint(x: size.width, y:CGRectGetMaxY(playableRect)),fromNode:self)
                if zombie.position.x <= bottomLeft.x { zombie.position.x = bottomLeft.x
            velocity.x = -velocity.x
            }
            if zombie.position.x >= topRight.x {
            zombie.position.x = topRight.x
            velocity.x = -velocity.x }
            if zombie.position.y <= bottomLeft.y { zombie.position.y = bottomLeft.y
                        velocity.y = -velocity.y
            }
            if zombie.position.y >= topRight.y {
                        zombie.position.y = topRight.y
                        velocity.y = -velocity.y }
    }
    func rotateSprite(sprite: SKSpriteNode, direction: CGPoint, zombieRotateRadiansPerSec:CGFloat) {
        //sprite.zRotation = direction.angle
//        if let lastTouch = lastTouchLocation {
//            let diff = lastTouch - zombie.position
        let shortest = shortestAngleBetween(sprite.zRotation, velocity.angle)
            let amtToRotate = zombieRotateRadiansPerSec * CGFloat(dt)
            if abs(shortest) > amtToRotate
            {
                sprite.zRotation += (shortest.sign() * amtToRotate)
            }
            else
            {
                sprite.zRotation += shortest
            }
            
//        }
        
    }
    func loseCats() { // 1
        var loseCount = 0
        backgroundLayer.enumerateChildNodesWithName("train") { node, stop in
        // 2
        var randomSpot = node.position
        randomSpot.x += CGFloat.random(min: -1000, max: 1000)
        randomSpot.y += CGFloat.random(min: -1000, max: 1000) // 3
        node.name = ""
        node.runAction(
        SKAction.sequence([ SKAction.group([
        SKAction.rotateByAngle(π*4, duration: 1.0), SKAction.moveTo(randomSpot, duration: 1.0), SKAction.scaleTo(0, duration: 1.0)
        ]),
        SKAction.removeFromParent() ]))
        // 4
        loseCount++
        if loseCount >= 2 {
        stop.memory = true }
        }
    }
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent)  {
                        if let touch = touches.first as? UITouch
                    {let touchLocation = touch.locationInNode(backgroundLayer)
                        
                        sceneTouched(touchLocation)}
                        super.touchesBegan(touches, withEvent: event)
    }
    func spawnEnemy() {
        let enemy = SKSpriteNode(imageNamed: "enemy")
            enemy.name = "enemy"
        enemy.position = backgroundLayer.convertPoint(CGPoint(x: size.width + enemy.size.width/2, y: CGFloat.random(
            min: CGRectGetMinY(playableRect) + enemy.size.height/2,
            max: CGRectGetMaxY(playableRect) - enemy.size.height/2)),fromNode:self)
        
//            enemy.setScale(0.5)
        backgroundLayer.addChild(enemy)
        let actionMove =
        SKAction.moveByX(-backgroundNode().size.width/2, y: 0, duration: 2.0)
        
//        SKAction.moveToX(-enemy.size.width/2, duration: 2.0)
        let actionRemove = SKAction.removeFromParent()
        enemy.runAction(SKAction.sequence([actionMove, actionRemove]))
        
}
func zombieHitCat(cat:SKSpriteNode){
 cat.name = "train"
                            
            cat.removeAllActions()
            cat.setScale(1.0)
            cat.zRotation = 0.0
            cat.runAction(SKAction.colorizeWithColor(UIColor.greenColor(), colorBlendFactor: 1.0, duration: 0.2))
            
runAction(catCollisionSound)
    }
    func moveTrain()
            {
        var trainCount = 0
                var targetPosition = zombie.position
                
                backgroundLayer.enumerateChildNodesWithName("train") {
           
            node, _ in
            trainCount++
            if !node.hasActions()
            {
            
    
            
                let actionDuration = 0.3
                let offset = targetPosition - node.position
                let direction = offset.normalized() * self.catSpeed
                    let amountToMove = direction * CGFloat(actionDuration)
                let moveAction = SKAction.moveByX(amountToMove.x, y: amountToMove.y, duration: actionDuration)
                    node.runAction(moveAction)
            if trainCount >= self.requirement && !self.gameOver {
    self.gameOver = true
    backgroundMusicPlayer.stop()
    let gameOverScene = GameOverScene(size: self.size, won:true)
    gameOverScene.scaleMode = self.scaleMode
    let reveal = SKTransition.flipHorizontalWithDuration(0.5)
    self.view?.presentScene(gameOverScene, transition: reveal)
            }
                 }
                targetPosition = node.position }
       
}
    
    func zombieHitEnemy(enemy:SKSpriteNode){
    blink()
    
        runAction(enemyCollisionSound)
                loseCats()
                
                removeheart()
                lives--
    

    }
    func checkCollisions() {
    
        var hitCats: [SKSpriteNode] = []
        backgroundLayer.enumerateChildNodesWithName("cat") { node, _ in
            let cat = node as! SKSpriteNode
            if CGRectIntersectsRect(cat.frame, self.zombie.frame)
            { hitCats.append(cat)
        }
        }
        for cat in hitCats
        {zombieHitCat(cat)}
        var hitEnemies: [SKSpriteNode] = []
        if zombieInvis == false
            {
        backgroundLayer.enumerateChildNodesWithName("enemy")
            { node, _ in
            let enemy = node as! SKSpriteNode
            if CGRectIntersectsRect(
            CGRectInset(node.frame, 20, 20), self.zombie.frame)
                {
            hitEnemies.append(enemy) }
        }
        for enemy in hitEnemies {
            zombieHitEnemy(enemy) }
        }
    }

}
