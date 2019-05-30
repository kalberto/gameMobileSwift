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
    
    var life = 3;
    var points = 0;
    var monsters = 10;
    var monstersKilled = 0;
    var delayTime = 3000;
    
    var lifeTexture: [SKTexture]!;
    var lifeSprite: SKSpriteNode!;
    var lifeNode:SKSpriteNode!;
    
    var lifeLabel: SKLabelNode!;
    var pointsNode: SKLabelNode!;
    
    var player: SKSpriteNode!;
    var target: SKShapeNode!;
    var isTargeting = false;
    var force = CGFloat(10);

    override func didMove(to view: SKView) {
        let titleNode = SKLabelNode(fontNamed: "Avenir-Book")
        titleNode.text = "Destrua as cobras"
        titleNode.fontSize = 25
        titleNode.position = CGPoint(x: titleNode.frame.width*0.5 , y: 20)
        titleNode.fontColor = #colorLiteral(red: 0.1490196139, green: 0.1490196139, blue: 0.1490196139, alpha: 1)
        titleNode.zPosition = 30;
        addChild(titleNode)
        
        lifeLabel = SKLabelNode(fontNamed: "Avenir-Book");
        lifeLabel.text = "Vidas: " + String( life);
        lifeLabel.fontSize = 20;
        lifeLabel.position = CGPoint(x: titleNode.frame.width + 20 + lifeLabel.frame.width*0.5, y:20)
        lifeLabel.fontColor = #colorLiteral(red: 0.1490196139, green: 0.1490196139, blue: 0.1490196139, alpha: 1);
        lifeLabel.zPosition = 30;
        addChild(lifeLabel);
        
        pointsNode = SKLabelNode(fontNamed: "Avenir-Book");
        pointsNode.text = "Pontos: " + String( points);
        pointsNode.fontSize = 20;
        var rigthPosX = lifeLabel.position.x + lifeLabel.frame.width*0.5;
        pointsNode.position = CGPoint(x: rigthPosX + 20 + pointsNode.frame.width*0.5, y:20)
        pointsNode.fontColor = #colorLiteral(red: 0.1490196139, green: 0.1490196139, blue: 0.1490196139, alpha: 1);
        pointsNode.zPosition = 30;
        addChild(pointsNode);
 
        
        player = self.childNode(withName: "Player") as? SKSpriteNode;
        setTarget();
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame);
        
        self.enumerateChildNodes(withName: "gorrilaWall") {
            (node, stop) in
            let body = SKPhysicsBody(rectangleOf: node.frame.size);
            body.affectedByGravity = true;
            node.physicsBody = body;
            node.name = "wall";
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
            var newLife = lifeSprite.copy() as! SKSpriteNode;
            var posX = lifeSprite.size.width*0.5 + lifeSprite.size.width * CGFloat(i) + 5 * CGFloat((i+1));
            var posY = self.frame.height - lifeSprite.size.height*0.5 - 5;
            newLife.position = CGPoint(x: posX,y: posY);
            lifeNode.addChild(newLife);
        }
        self.addChild(lifeNode);
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if(contact.bodyA.node?.name == "ground" && contact.bodyB.node?.name == "Snake" ){
            contact.bodyB.node?.removeFromParent();
        }else if(contact.bodyA.node?.name == "Snake" && contact.bodyB.node?.name == "ground"){
            contact.bodyA.node?.removeFromParent();
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
        player.physicsBody = body;
    }
    
    func fire(){
        let deltaX = player.position.x - target.position.x;
        let deltaY = player.position.y - target.position.y;
        
        let impulse = CGVector(dx: deltaX*force,dy: deltaY*force);
        player.physicsBody?.applyImpulse(impulse);
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if(player.contains(pos)){
            isTargeting = true;
            target.isHidden = false;
            target.position = pos;
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        target.position = pos;
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if(isTargeting){
            if(player.physicsBody == nil){
                setPhysicsBody();
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
    }
}
