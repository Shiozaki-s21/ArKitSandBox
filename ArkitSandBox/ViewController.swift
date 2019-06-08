//
//  ViewController.swift
//  ArkitSandBox
//
//  Created by SubaruShiozaki on 2019-05-23.
//  Copyright © 2019 Kazuya Takahashi. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController {
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var hitLabel: UILabel! {
    didSet {
      hitLabel.isHidden = true
    }
  }

  lazy var kightNode: SCNNode = {
    // Create a new SCNScene as a kight
    let kight = SCNScene(named: "art.scnassets/kight.scn")!
    
    // Create node for kight
    let kightNode: SCNNode = SCNNode()
    var nodeArray = kight.rootNode.childNodes
    kightNode.name = "kight"
    kightNode.position = SCNVector3(0, 0, 0)
    for childNode in nodeArray {
      kightNode.addChildNode(childNode as SCNNode)
    }
    
    // to add BodyShape
    let shape = SCNPhysicsShape(node: kightNode, options: nil)
    // to add hitting
    // .dynamic -> it's movable after hitting
    // .static -> no hit
    // .kinematic -> it's not movable after hitting
    kightNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: shape)
    kightNode.physicsBody?.isAffectedByGravity = false
    kightNode.position = SCNVector3Make(0, 0, 0)
    return kightNode
  }()
  
  let defaultConfiguration: ARWorldTrackingConfiguration = {
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    configuration.environmentTexturing = .automatic
    return configuration
  }()
  
  
  
  //  lazy var boxNode: SCNNode = {
  //    let cylinder = SCNCylinder(radius: 0.1, height: 0.05)
  //    let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
  //    box.firstMaterial?.diffuse.contents = UIColor.red
  //    let node = SCNNode(geometry: box)
  //    node.name = "box"
  //    node.position = SCNVector3Make(0, 0, -1.5)
  //
  //    // add PhysicsShape
  //    let shape = SCNPhysicsShape(geometry: box, options: nil)
  //    node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
  //    node.physicsBody?.isAffectedByGravity = false
  //
  //    return node
  //  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Set the view's delegate
//    sceneView.delegate = self
    
    sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    sceneView.autoenablesDefaultLighting = true
    sceneView.scene.physicsWorld.contactDelegate = self
    
    // add new model
    // Set the scene to the view
//     sceneView.scene = SCNScene()
    sceneView.scene.rootNode.addChildNode(kightNode)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    // set configration
    let configuration = ARWorldTrackingConfiguration()
    
    // search horizon
    configuration.planeDetection = .horizontal
    
    // set light information
    configuration.isLightEstimationEnabled = true
    
    sceneView.session.run(defaultConfiguration)
  }
  
//  override func viewWillDisappear(_ animated: Bool) {
//    super.viewWillDisappear(animated)
//
//    sceneView.session.pause()
//  }
//
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    let ball = SCNSphere(radius: 0.1)
    ball.firstMaterial?.diffuse.contents = UIColor.blue
    
    let node = SCNNode(geometry: ball)
    node.name = "ball"
    node.position = SCNVector3Make(0, 0.1, 0)
    
    // add PhysicsShape
    let shape = SCNPhysicsShape(geometry: ball, options: nil)
    node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
    node.physicsBody?.contactTestBitMask = 1
    node.physicsBody?.isAffectedByGravity = false
    
    if let camera = sceneView.pointOfView {
      node.position = camera.position
      
      let toPositionCamera = SCNVector3Make(0, 0, -3)
      let toPosition = camera.convertPosition(toPositionCamera, to: nil)
      
      let move = SCNAction.move(to: toPosition, duration: 0.5)
      move.timingMode = .easeOut
      node.runAction(move) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          node.removeFromParentNode()
        }
      }
    }
    sceneView.scene.rootNode.addChildNode(node)
  }
  
  func startGame() {
    // after tapped start button
    
    // start countdown
    
    // count time
    
    // before enemy shooting, player tapped
    
    // after enemy shootingm, player tapped or pla
  }
}

extension ViewController: SCNPhysicsContactDelegate {
  func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    let nodeA = contact.nodeA
    let nodeB = contact.nodeB
    
    if (nodeA.name == "kight" && nodeB.name == "ball")
      || (nodeB.name == "kight" && nodeA.name == "ball"){
      
      DispatchQueue.main.async {
        self.hitLabel.text = "HIT!!"
        self.hitLabel.sizeToFit()
        self.hitLabel.isHidden = false
        
        // Vibration
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          self.hitLabel.isHidden = true
        }
      }
    }
  }
}

//Mark:- position problem
//extension ViewController: ARSCNViewDelegate {
//  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//    print(node.position)
//
//    node.addChildNode(kightNode)
//  }
//
//  func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//    print(node.position)
//  }
//
//}
