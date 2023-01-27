//
//  GameScene.swift
//  DGarciaJuegoCandyCrush
//
//  Created by MacBookMBA3 on 18/01/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var pokemonTapped : SKSpriteNode!
    var touched : Bool!
    var matchedRow : [SKSpriteNode] = []
    var matchedCol : [SKSpriteNode] = []
    var matchedRowTwo : [SKSpriteNode] = []
    var matchedColTwo : [SKSpriteNode] = []
    let namePokemon = ["bulbasur","butterfree","pikachu","squirtle","mudkip","octillery"]
    var mathedflag : Bool = false
    var terminaRevision : Bool = false {
        didSet {
            if terminaRevision == false {
                print("aun no temino de revisar")
                //ReviarTablero()
                RevisarTableroRecursivo(filaIncrementa: -400, incrementa: self.size.width/5)
                //RevisarTableroRecursivo(filaIncrementa: -400, incrementa: self.size.width/5)
            } else {
                print("Termine de revisar")
            }
        }
    }
    var lastFromNodePokemon : CGPoint = CGPoint(x: 0, y: 0)
    var lastToNodePokemo : CGPoint = CGPoint(x: 0, y: 0)
    
    override func didMove(to view: SKView) {
        createArray()
        RevisarTableroRecursivo(filaIncrementa: -400, incrementa: self.size.width/5)
    }
    
    
    
    func createArray() {
        
        for i in stride(from: -self.size.width/2 + self.size.width/5, to: self.size.width/2, by: self.size.width/5){
            for j in stride(from: -400, to: self.size.width/2, by: self.size.width/5){
                let name = namePokemon.randomElement()!
                let pokemon = SKSpriteNode(texture: SKTexture(imageNamed: name))
                pokemon.name = name
                pokemon.position = CGPoint(x: i, y: j)
                pokemon.size = CGSize(width: 100, height: 100)
                addChild(pokemon)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        
        if let pokemon = nodes(at: location).first as? SKSpriteNode {
            pokemonTapped = pokemon
            touched = true
        }
    }
    
    func ordenaHorizontalRecursivo(aumento: CGFloat, incremento: CGFloat, coordenadaX: CGFloat){
        
        if self.size.width/2 < aumento + incremento  {
            let name = namePokemon.randomElement()!
            let pokemon = SKSpriteNode(texture: SKTexture(imageNamed: name))
            pokemon.name = name
            pokemon.position = CGPoint(x: coordenadaX, y: aumento)
            pokemon.size = CGSize(width: 100, height: 100)
            self.addChild(pokemon)
        } else {
            let nodo = self.nodes(at: CGPoint(x: coordenadaX, y: aumento + incremento))
            nodo[0].position = CGPoint(x: nodo[0].position.x, y: nodo[0].position.y - incremento)
            ordenaHorizontalRecursivo(aumento: aumento + incremento, incremento: incremento, coordenadaX: coordenadaX)
        }
        
    }
    
    func rellenaVerticalRecursivo(aumento: CGFloat, incremento: CGFloat, coordenadaX: CGFloat, pokemonAgrega: Int) {
       
        if pokemonAgrega == 0 {
            return
        } else {
            let name = namePokemon.randomElement()!
            let pokemon = SKSpriteNode(texture: SKTexture(imageNamed: name))
            pokemon.name = name
            pokemon.position = CGPoint(x: coordenadaX, y: aumento)
            pokemon.size = CGSize(width: 100, height: 100)
            self.addChild(pokemon)
            rellenaVerticalRecursivo(aumento: aumento + incremento, incremento: incremento, coordenadaX: coordenadaX, pokemonAgrega: pokemonAgrega - 1)
        }
        
    }
    
    
    func ordenaVerticalRecursivo(aumento: CGFloat, incremento: CGFloat, coordenadaX: CGFloat, PokemonAgrega: Int)  {
        
        if self.size.width/2 < aumento + incremento {
            rellenaVerticalRecursivo(aumento: aumento, incremento: self.size.width/5, coordenadaX: coordenadaX, pokemonAgrega: PokemonAgrega)
        } else {
            let newPosY = aumento + incremento
            let nodo = self.nodes(at: CGPoint(x: coordenadaX, y: newPosY))
            nodo[0].position = CGPoint(x: coordenadaX, y: aumento)
            ordenaVerticalRecursivo(aumento: aumento + self.size.width/5, incremento: incremento, coordenadaX: coordenadaX, PokemonAgrega: PokemonAgrega)
        }
    }
    
    func createPokemon(matched: inout [SKSpriteNode]){
        
        if matched.count >= 3 {
            mathedflag = true
            
            matched = matched.sorted(by: {$0.position.y < $1.position.y})
            var points : [CGPoint] = []
            
            for pokemon in matched {
                points.append(pokemon.position)
            }
            
            for pokemon in matched {
                pokemon.removeFromParent()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(200)) {
                let orientation = points[0].x == points[1].x ? "Vertical" : "Horizontal"
                
                if orientation == "Horizontal" {
                    for p in points {
                        self.ordenaHorizontalRecursivo(aumento: p.y, incremento: CGFloat(self.size.width/2.5/2), coordenadaX: p.x)
                    }
                } else if orientation == "Vertical" {
                    self.ordenaVerticalRecursivo(aumento: points[0].y, incremento: CGFloat(self.size.width/5) * CGFloat((points.count)), coordenadaX: points[0].x, PokemonAgrega: points.count)
                }
            }
        }
    }
    
    func createBackMove(FromNode: SKSpriteNode, ToNode: SKSpriteNode){
        let positionA = FromNode.position
        let positionB = ToNode.position
        
        let moveOne = SKAction.move(to: positionB, duration: 0.15)
        let moveTwo = SKAction.move(to: positionA, duration: 0.15)
        
        FromNode.run(moveOne)
        ToNode.run(moveTwo)
    }
    
    func createMove(FromNode: SKSpriteNode, ToNode: SKSpriteNode ){
        let positionA = FromNode.position
        let positionB = ToNode.position
        let moveOne = SKAction.move(to: positionB, duration: 0.15)
        let moveTwo = SKAction.move(to: positionA, duration: 0.15)
        
        let checkOne = SKAction.run {
            self.matchedRow.removeAll()
            self.matchedCol.removeAll()
            
            self.check(pokemon: FromNode, x: self.size.width/5, y: 0, pokemonMatched: &self.matchedRow)
            self.check(pokemon: FromNode, x: 0, y: self.size.width/5, pokemonMatched: &self.matchedCol)
            
            self.createPokemon(matched: &self.matchedRow)
            self.createPokemon(matched: &self.matchedCol)
        }
        
        let checkTwo = SKAction.run {
            
            self.matchedRowTwo.removeAll()
            self.matchedColTwo.removeAll()
            
            self.check(pokemon: ToNode, x: self.size.width/5, y: 0, pokemonMatched: &self.matchedRowTwo)
            self.check(pokemon: ToNode, x: 0, y: self.size.width/5, pokemonMatched: &self.matchedColTwo)
            
            self.createPokemon(matched: &self.matchedRowTwo)
            self.createPokemon(matched: &self.matchedColTwo)
        }
        
        
        
        let sequence = SKAction.sequence([moveOne,checkOne])
        let sequenceTwo = SKAction.sequence([moveTwo,checkTwo])
        
        FromNode.run(sequence)
        ToNode.run(sequenceTwo)
        
    }
    
    func check(pokemon: SKSpriteNode, x: CGFloat, y: CGFloat, pokemonMatched: inout [SKSpriteNode]) {
        if let pokemonTam = nodes(at: CGPoint(x: pokemon.position.x + x, y: pokemon.position.y + y)).first as? SKSpriteNode {
            if !pokemonMatched.contains(pokemonTam){
                if pokemonTam.name == pokemon.name {
                    pokemonMatched.append(pokemonTam)
                    check(pokemon: pokemonTam, x: x, y: y, pokemonMatched: &pokemonMatched)
                }
            }
        }
        if let pokemonTam = nodes(at: CGPoint(x: pokemon.position.x - x, y: pokemon.position.y - y)).first as? SKSpriteNode {
            if !pokemonMatched.contains(pokemonTam){
                if pokemonTam.name == pokemon.name {
                    pokemonMatched.append(pokemonTam)
                    check(pokemon: pokemonTam, x: x, y: y, pokemonMatched: &pokemonMatched)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        if let pokemonMove = nodes(at: location).first as? SKSpriteNode{
            if pokemonTapped != pokemonMove && touched && (pokemonTapped.position.x == pokemonMove.position.x || pokemonTapped.position.y == pokemonMove.position.y){
                touched = false
                lastFromNodePokemon = pokemonTapped.position
                lastToNodePokemo = pokemonMove.position
                createMove(FromNode: pokemonTapped, ToNode: pokemonMove)
                
            }
        }
    }
    
    func RevisarColumnaTableroRecursivo(columnaIncrementa : CGFloat, filaIncrementa : CGFloat, incrementa : CGFloat) -> CGFloat {
        if self.size.width/2 <= columnaIncrementa {
            return filaIncrementa
        } else {
            let node = nodes(at: CGPoint(x: columnaIncrementa, y: filaIncrementa))

            self.matchedRow.removeAll()
            self.matchedCol.removeAll()

            self.check(pokemon: node[0] as! SKSpriteNode, x: self.size.width/5, y: 0, pokemonMatched: &self.matchedRow)
            self.check(pokemon: node[0] as! SKSpriteNode, x: 0, y: self.size.width/5, pokemonMatched: &self.matchedCol)
            print(node[0].name)
            if matchedRow.count >= 3{
                createPokemon(matched: &matchedRow)
                DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(500)){
                    self.terminaRevision = false
                }
                return -400 - self.size.width/5
            } else if matchedCol.count >= 3 {
                createPokemon(matched: &matchedCol)
                DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(500)){
                    self.terminaRevision = false
                }
                return -400 - self.size.width/5
            }
            return RevisarColumnaTableroRecursivo(columnaIncrementa: columnaIncrementa + incrementa, filaIncrementa: filaIncrementa, incrementa: incrementa)
        }
    }
    
    
    func RevisarTableroRecursivo(filaIncrementa : CGFloat, incrementa : CGFloat){
        if self.size.width/2 < filaIncrementa {
            return
        } else {
            var valorfilaIncrementa = RevisarColumnaTableroRecursivo(columnaIncrementa: -self.size.width/2 + self.size.width/5, filaIncrementa: filaIncrementa, incrementa: incrementa)
            print("-------------------------")
            if valorfilaIncrementa >= -400{
                RevisarTableroRecursivo(filaIncrementa: valorfilaIncrementa + incrementa, incrementa: incrementa)
            } else {
                return
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if mathedflag {
            // MATCH EXISTENTE
            mathedflag = false
            RevisarTableroRecursivo(filaIncrementa: -400, incrementa: self.size.width/5)
        } else {
            // MATCH NO EXISTENTE
            let node = nodes(at: lastFromNodePokemon)
            let nodeBack = nodes(at: lastToNodePokemo)
            DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(200)) {
                self.createBackMove(FromNode: node[0] as! SKSpriteNode, ToNode: nodeBack[0] as! SKSpriteNode)
            }
        }
    }
    
}
