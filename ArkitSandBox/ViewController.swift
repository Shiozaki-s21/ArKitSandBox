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
  
  let defaultConfiguration: ARWorldTrackingConfiguration = {
    let configuration = ARWorldTrackingConfiguration()
    configuration.planeDetection = .horizontal
    configuration.environmentTexturing = .automatic
    return configuration
  }()
  
  lazy var boxNode: SCNNode = {
    let cylinder = SCNCylinder(radius: 0.1, height: 0.05)
    let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.01)
    box.firstMaterial?.diffuse.contents = UIColor.red
    let node = SCNNode(geometry: box)
    node.name = "box"
    node.position = SCNVector3Make(0, 0, -1.5)
    
    // add PhysicsShape
    let shape = SCNPhysicsShape(geometry: box, options: nil)
    node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
    node.physicsBody?.isAffectedByGravity = false
    
    return node
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    sceneView.autoenablesDefaultLighting = true
    sceneView.scene.physicsWorld.contactDelegate = self
    
    sceneView.scene.rootNode.addChildNode(boxNode)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    sceneView.session.run(defaultConfiguration)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    sceneView.session.pause()
  }
  
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
  
}

extension ViewController: SCNPhysicsContactDelegate {
  func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
    let nodeA = contact.nodeA
    let nodeB = contact.nodeB
    
    if (nodeA.name == "box" && nodeB.name == "ball")
      || (nodeB.name == "box" && nodeA.name == "ball"){
      
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



////ViewController
//
//class ViewController: UIViewController, ARSCNViewDelegate {
//
//  @IBOutlet var sceneView: ARSCNView!
//
//
//  lazy var kightNode: SCNNode = {
//    // Create a new scene as a kight
//    let kight = SCNScene(named: "art.scnassets/kight.scn")!
//
//    // Create node for kight
//    let kightNode:SCNNode = SCNNode()
//    var nodeArray = kight.rootNode.childNodes
//    kightNode.name = "kight"
//    kightNode.position = SCNVector3Make(0, 0, 0)
//    for childNode in nodeArray {
//      kightNode.addChildNode(childNode as SCNNode)
//
//    }
//    return kightNode
//  }()
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//
//    // Set the view's delegate
//    sceneView.delegate = self
//
//    // Show statistics such as fps and timing information
//    sceneView.showsStatistics = true
//
//    // Create a new scene as a Ship
//    let ship = SCNScene(named:"art.scnassets/ship.scn")!
//
//    // Set the scene to the view
////        sceneView.scene = kightNode
//    sceneView.scene.rootNode.addChildNode(kightNode)
//
//
//
//  }
//
//  override func viewWillAppear(_ animated: Bool) {
//    super.viewWillAppear(animated)
//
//    // Create a session configuration
//    let configuration = ARWorldTrackingConfiguration()
//
//    // Run the view's session
//    sceneView.session.run(configuration)
//  }
//
//  override func viewWillDisappear(_ animated: Bool) {
//    super.viewWillDisappear(animated)
//
//    // Pause the view's session
//    sceneView.session.pause()
//  }
//
//  // MARK: - ARSCNViewDelegate
//
//  /*
//   // Override to create and configure nodes for anchors added to the view's session.
//   func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
//   let node = SCNNode()
//
//   return node
//   }
//   */
//
//  func session(_ session: ARSession, didFailWithError error: Error) {
//    // Present an error message to the user
//
//  }
//
//  func sessionWasInterrupted(_ session: ARSession) {
//    // Inform the user that the session has been interrupted, for example, by presenting an overlay
//
//  }
//
//  func sessionInterruptionEnded(_ session: ARSession) {
//    // Reset tracking and/or remove existing anchors if consistent tracking is required
//
//  }
//
//  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//    let ball = SCNSphere(radius: 0.1)
//    ball.firstMaterial?.diffuse.contents = UIColor.blue
//
//    let node = SCNNode(geometry: ball)
//    node.name = "ball"
//    node.position = SCNVector3Make(0, 0.1, 0)
//
//    // add PhysicsShape
//    let shape = SCNPhysicsShape(geometry: ball, options: nil)
//    node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: shape)
//    node.physicsBody?.contactTestBitMask = 1
//    node.physicsBody?.isAffectedByGravity = false
//
//    if let camera = sceneView.pointOfView {
//      node.position = camera.position
//
//      let toPositionCamera = SCNVector3Make(0, 0, -3)
//      let toPosition = camera.convertPosition(toPositionCamera, to: nil)
//
//      let move = SCNAction.move(to: toPosition, duration: 0.5)
//      move.timingMode = .easeOut
//      node.runAction(move) {
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//          node.removeFromParentNode()
//        }
//      }
//    }
//    sceneView.scene.rootNode.addChildNode(node)
//  }
//}
//
//extension ViewController: SCNPhysicsContactDelegate {
//  func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
//    let nodeA = contact.nodeA
//    let nodeB = contact.nodeB
//
//    if (nodeA.name == "kight" && nodeB.name == "ball")
//      || (nodeB.name == "kight" && nodeA.name == "ball")
//      || (nodeB.name == "ball" && nodeA.name == "ball"){
//
//      DispatchQueue.main.async {
//        print("Hit")
//        // Vibration
//        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//          //          self.hitLabel.isHidden = true
//        }
//      }
//    }
//  }
//}
