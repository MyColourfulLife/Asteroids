- 自定义DynamicBehavior
  添加各种自定义行为,在初始化时添加
  ```swift
      override init() {
        super.init()
        addChildBehavior(collider)
        addChildBehavior(physics)
        addChildBehavior(acceleration)
        physics.action  = { [weak self] in
            for asteroid in self?.asteroids ?? [] {
                let velocity = self!.physics.linearVelocity(for: asteroid)
                let excessHorizontalVelocity = min(self!.speedLimit - velocity.x, 0)
                let excessVerticalVelocity = min(self!.speedLimit - velocity.y, 0)
                self!.physics.addLinearVelocity(CGPoint(x: excessHorizontalVelocity, y: excessVerticalVelocity), for: asteroid)
            }
        }
    }
    ```
    各种行为添加项目时注意在合适的地方成对移除。
- 使用碰撞行为：
    碰撞模式，碰撞事件处理
    ```swift
        private lazy var collider: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.collisionMode = .boundaries
        //        behavior.translatesReferenceBoundsIntoBoundary = true
        behavior.collisionDelegate = self
        return behavior
    }()
    ```
- 使用物理行为:
    弹性系数，阻尼系数，摩擦系数，允许旋转
    ```swift
        private lazy var physics: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.elasticity = 1// 弹性碰撞
        behavior.allowsRotation = true
        behavior.friction = 0//摩擦系数
        behavior.resistance = 0//阻尼，阻力
        return behavior
    }()
    ```
- 加速度:
    重力行为，设置加速度
```swift
        lazy var acceleration: UIGravityBehavior = {
        let behavior = UIGravityBehavior()
        behavior.magnitude = 0
        return behavior
    }()
```
- 使用动画图像
```swift
        static let explosionImage = UIImage.animatedImageNamed("explosion", duration: 1.5)
        imageView.image = Constants.explosionImage
        imageView.transform = CGAffineTransform.identity
        imageView.startAnimating()
```
- 使用自定义绘图
```swift
  private func getSheildPath(level:Double = 100,in view:UIView? = nil)->UIBezierPath {
        var middle = CGPoint(x: bounds.midX, y: bounds.midY)
        if view != nil {
            middle = self.convert(middle, to: view)
        }
        let radius = min(bounds.size.width, bounds.size.height)/2 - shieldLinewidth
        let startAngle = -CGFloat.pi/2
        let endAngle = -CGFloat.pi/2 + CGFloat(level)/100 * CGFloat.pi*2
        let path = UIBezierPath(arcCenter: middle, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.lineWidth = shieldLinewidth * (shieldIsActive ? Constants.shieldActiveLinewidthRatio : 1)
        return path
    }
    private var shieldColor:UIColor {
        let red:CGFloat = shieldLevel < 50 ? 1 : 0
        let green:CGFloat = shieldLevel > 25 ? 1 : 0
        return UIColor(red: red, green: green, blue: 0, alpha: 1)
    }
    
    override func draw(_ rect: CGRect) {
        if shieldLevel > 0 && shieldLevel < 100 && !exploading {
            UIColor.lightGray.setStroke()
            getSheildPath().stroke()
            shieldColor.setStroke()
            getSheildPath(level: shieldLevel).stroke()
        }
    }
```
- 使用UIView动画创建爆炸效果
```swift
    var exploading:Bool {
        return imageView.image == Constants.explosionImage
    }
        private func explode() {
        imageView.image = Constants.explosionImage
        imageView.transform = CGAffineTransform.identity
        imageView.startAnimating()
        setNeedsDisplay()
        
        let smallerFrame = imageView.frame.insetBy(
            dx: imageView.bounds.size.width * 0.30,
            dy: imageView.bounds.size.height * 0.30)
        let biggerFrame = imageView.frame.insetBy(
            dx: -imageView.bounds.size.width*0.15,
            dy: -imageView.bounds.size.height*0.15)
        let explodeTime = Constants.explosionDuration * Constants.explosionToFadeRatio
        UIView.animate(withDuration: explodeTime, animations: {[imageView = self.imageView] in
            imageView.frame = biggerFrame
        }) { finished in
            UIView.animate(withDuration: Constants.explosionDuration, animations: {[imageView = self.imageView] in
                imageView.alpha = 0
                imageView.frame = smallerFrame
            }, completion: { finished in
                self.resetShipImage()
            })
        }
    }
    
    private func resetShipImage() {
        imageView.isHidden = shieldLevel == 0
        if imageView.superview == nil {
            isOpaque = false
            addSubview(imageView)
        }
        imageView.image = enginesAreFiring ? Constants.shipWithEnginesFiringImage : Constants.shipImage
        updateImageViewFrame()
        updateDirection()
        imageView.alpha = 1
    }
    ```
