//
//  GameScene.swift
//  Aula3
//
//  Created by ALUNO on 15/05/2019.
//  Copyright © 2019 ALUNO. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var isPlaying = false;
    var life = 3;
    var points = 0;
    var monsters = 10;
    var monstersKilled = 0;
    var delayTime = 3000;
    
    var gameOver = false;
    var startOver = false;
    
    var framesCount = 0;
    var startPos: CGPoint!;
    
    var sound: SKAction!;
    
    var lifeTexture: [SKTexture]!;
    var lifeSprite: SKSpriteNode!;
    var lifeNode:SKSpriteNode!;
    
    var pointsNode: SKLabelNode!;
    var titleNode: SKLabelNode!;
    
    var player: SKSpriteNode!;
    var target: SKShapeNode!;
    var isTargeting = false;
    var force = CGFloat(10);

    override func didMove(to view: SKView) {
        sound = SKAction.playSoundFileNamed("snakeDeath.wav", waitForCompletion: false);
        titleNode = SKLabelNode(fontNamed: "Avenir-Book")
        titleNode.text = "Destrua as cobras"
        titleNode.fontSize = 40
        titleNode.position = CGPoint(x: titleNode.frame.width*0.5 , y: 75)
        titleNode.fontColor = #colorLiteral(red: 0.1490196139, green: 0.1490196139, blue: 0.1490196139, alpha: 1)
        titleNode.zPosition = 30;
        addChild(titleNode)
        
        pointsNode = SKLabelNode(fontNamed: "Avenir-Book");
        pointsNode.text = "Pontos: " + String( points);
        pointsNode.fontSize = 40;
        pointsNode.position = CGPoint(x: titleNode.frame.width + 20 + pointsNode.frame.width*0.5, y:75)
        pointsNode.fontColor = #colorLiteral(red: 0.1490196139, green: 0.1490196139, blue: 0.1490196139, alpha: 1);
        pointsNode.zPosition = 30;
        addChild(pointsNode);
 
        
        player = self.childNode(withName: "Player") as? SKSpriteNode;
        player.name = "player";
        startPos = player.position;
        setTarget();
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame);
        
        self.enumerateChildNodes(withName: "gorrilaWall") {
            (node, stop) in
            let body = SKPhysicsBody(rectangleOf: node.frame.size);
            body.affectedByGravity = true;
            node.physicsBody = body;
            node.physicsBody?.contactTestBitMask = Masks.playerMask;
            node.physicsBody?.categoryBitMask = Masks.wallMask;
            node.name = "wall";
            node.userData = NSMutableDictionary();
            node.userData?.setValue(100, forKey: "life");
        }
        
        self.enumerateChildNodes(withName: "snakePoint") {
            (node, stop) in
            let body = SKPhysicsBody(rectangleOf: node.frame.size);
            body.affectedByGravity = true;
            node.physicsBody = body;
            node.name = "snake";
        }
        
        startLifeTextures();
        
        let ground = childNode(withName: "ground");
        ground?.physicsBody?.categoryBitMask = Masks.groundMask;
        ground?.physicsBody?.contactTestBitMask = Masks.snakeMask;
        physicsWorld.contactDelegate = self;
    }
    
    func startLifeTextures(){
        lifeNode = SKSpriteNode();
        let atlas = SKTextureAtlas(named: "life")
        var lifeTexture = [SKTexture]()
        for i in 0..<atlas.textureNames.count{
            let texName = "chick\(i)"
            lifeTexture.append(atlas.textureNamed(texName))
        }
        lifeSprite = SKSpriteNode(texture: lifeTexture[0]);
        lifeSprite.size.width = 30;
        lifeSprite.size.height = 30;
        let animAction = SKAction.animate(with: lifeTexture, timePerFrame: 0.08)
        lifeSprite.run(SKAction.repeatForever(animAction))
        lifeSprite.zPosition = 30
        for i in 0..<life{
            let newLife = lifeSprite.copy() as! SKSpriteNode;
            let posX = lifeSprite.size.width*0.5 + lifeSprite.size.width * CGFloat(i) + 5 * CGFloat((i+1));
            let posY = self.frame.height - lifeSprite.size.height*0.5 - 50;
            newLife.position = CGPoint(x: posX,y: posY);
            lifeNode.addChild(newLife);
        }
        self.addChild(lifeNode);
    }
    
    func addParticle(position:CGPoint){
        if let particle = SKEmitterNode(fileNamed: "SnakeExplosion.sks"){
            particle.position = CGPoint(x: 0, y: 0);
            particle.zPosition = 29;
            particle.numParticlesToEmit = 70;
            particle.position = position;
            
            let addEmitterAction = SKAction.run({self.addChild(particle)});
            
            var emitterDuration = CGFloat(particle.numParticlesToEmit) * particle.particleLifetime;
            
            let wait = SKAction.wait(forDuration: Double(emitterDuration));
            
            let remove = SKAction.run({particle.removeFromParent();});
            
            let sequence = SKAction.sequence([addEmitterAction, wait, remove]);
            
            self.run(sequence);
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if(contact.bodyA.node?.name == "ground" && contact.bodyB.node?.name == "snake" ){
            contact.bodyB.node?.removeFromParent();
            addParticle(position: (contact.bodyB.node?.position)!);
            killSnake();
        }else if(contact.bodyA.node?.name == "snake" && contact.bodyB.node?.name == "ground"){
            contact.bodyA.node?.removeFromParent();
            addParticle(position: (contact.bodyA.node?.position)!);
            killSnake();
        }
        if(contact.bodyA.node?.name == "player" && contact.bodyB.node?.name == "wall" ){
            //var damage = player.physicsBody
            let currentLife = contact.bodyB.node?.userData?["life"] as! Float;
            let life = currentLife - Float(contact.collisionImpulse);
            if(life <= 0){
                contact.bodyB.node?.removeFromParent();
            }else{
                contact.bodyB.node?.userData?["life"] = life;
            }
        }else if(contact.bodyA.node?.name == "wall" && contact.bodyB.node?.name == "player"){
            let currentLife = contact.bodyA.node?.userData?["life"] as! Float;
            let life = currentLife - Float(contact.collisionImpulse);
            if(life <= 0){
                contact.bodyA.node?.removeFromParent();
            }else{
                contact.bodyA.node?.userData?["life"] = life;
            }
        }
    }
    
    func setTarget(){
        target = SKShapeNode(circleOfRadius: 10);
        target.fillColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1);
        target.strokeColor = UIColor.clear;
        target.isHidden = true;
        target.zPosition = 1;
        self.addChild(target);
    }
    
    func setPhysicsBody(){
        let body = SKPhysicsBody(circleOfRadius: player.frame.width*0.5);
        body.isDynamic = true;
        body.affectedByGravity = true;
        body.allowsRotation = true;
        body.mass = 1;
        body.categoryBitMask = Masks.playerMask;
        body.contactTestBitMask = Masks.snakeMask;
        body.linearDamping = 1;
        body.angularDamping = 1;
        player.physicsBody = body;
    }
    
    func restartPhysicBody(){
        player.physicsBody?.isDynamic = true;
        player.physicsBody?.affectedByGravity = true;
        player.physicsBody?.allowsRotation = true;
    }
    
    func stopPhysicBody(){
        player.physicsBody?.isDynamic = false;
        player.physicsBody?.affectedByGravity = false;
        player.physicsBody?.allowsRotation = false;
    }
    
    func killSnake(){
        run(sound);
        points += 1;
    }
    
    func startResetScene(){
        gameOver = true;
        let wait = SKAction.wait(forDuration: 2.0);
        let reset = SKAction.run {
            self.startOver = true;
        };
        let sequence = SKAction.sequence([wait, reset]);
        run(sequence);
    }
    
    func resetScene(){
        let scene = SKScene(fileNamed: "GameScene");
        let transition = SKTransition.fade(withDuration: 2.0);
        scene?.scaleMode = .aspectFill;
        self.view!.presentScene((scene)!, transition: transition);
    }
    
    func die(){
        stopPhysicBody();
        if(life > 0){
            lifeNode.children.last!.removeFromParent();
            isPlaying = false;
            player.position = startPos;
            life -= 1;
        }else{
            //TODO
            titleNode.text = "Você perdeu!!";
            startResetScene();
        }
    }
    
    func win(){
        titleNode.text = "Você ganhou !!";
        startResetScene();
    }
    
    func fire(){
        let deltaX = player.position.x - target.position.x;
        let deltaY = player.position.y - target.position.y;
        
        let impulse = CGVector(dx: deltaX*force,dy: deltaY*force);
        player.physicsBody?.applyImpulse(impulse);
        isPlaying = true;
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if(!isPlaying){
            if(player.contains(pos)){
                isTargeting = true;
                target.isHidden = false;
                target.position = pos;
            }
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        target.position = pos;
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if(isTargeting){
            if(player.physicsBody == nil){
                setPhysicsBody();
            }else{
                restartPhysicBody();
            }
            fire();
            isTargeting = false;
            target.isHidden = true;
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        updateUI();
        updatePlayer();
        if (points >= 3){
            win();
        }
        
        if(gameOver && startOver){
            resetScene();
        }
    }
    
    //UPDATES
    func updatePlayer(){
        //CGVector
        if(isPlaying && getMag(vec: (player.physicsBody?.velocity)!) <= 0.001){
            framesCount += 1;
            if(framesCount > 60){
                die();
                framesCount = 0;
            }
        }else{
            framesCount = 0;
        }
    }
    
    func updateUI(){
        pointsNode.text = "Pontos: " + String( points);
    }
    
    //HELPERS
    func getMag(vec: CGVector) -> CGFloat {
        return sqrt(vec.dx * vec.dx * vec.dy * vec.dy);
    }
    
    
    
}
