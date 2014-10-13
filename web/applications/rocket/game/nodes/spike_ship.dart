part of ranger_rocket;

class SpikeShip extends PolygonNode with Ranger.VisibilityBehavior, Ranger.GroupingBehavior {
  static const double MAX_MAGNITUDE = 10.0;
  static const double MAX_THRUST_MAGNITUDE = 0.1;
  
  Ranger.Velocity _thrust = new Ranger.Velocity();
  Ranger.Velocity _momentum = new Ranger.Velocity();
  
  bool _pulseOn = false;
  double _pulseDuration = 0.0;
  double _pulseDurationCount = 0.0;
  double _pulseAngle = 0.0;
  double _pulseMag = 1.0;
  Ranger.Velocity _pulseForce = new Ranger.Velocity();

  bool _thrustOn = false;
  bool _rotateCWOn = false;
  bool _rotateCCWOn = false;
  double angle = 0.0;
  double thrustAngle = 0.0;
  double angularSpeed = 3.0;

  // ------------------------------------------------------------
  // Exhaust particle system.
  // ------------------------------------------------------------
  Ranger.ParticleSystem _exhaustPS;
  // The relative location for the exhaust
  Ranger.EmptyNode _exhaustPort = new Ranger.EmptyNode();
  
  // ------------------------------------------------------------
  // Gun particle system.
  // ------------------------------------------------------------
  Ranger.ParticleSystem gunPS;
  // The relative location for the gun
  Ranger.EmptyNode _gunPort = new Ranger.EmptyNode();
  bool _firing = false;
  
  Ranger.Velocity _bulletVelocity = new Ranger.Velocity();
  
  Vector2 motionPosition = new Vector2.zero();
  
  Ranger.BaseNode _mainLayer;

  double baseScale = 1.0;
  
  SpikeShip();

  SpikeShip._();
  
  factory SpikeShip.basic() {
    SpikeShip node = new SpikeShip._();
    
    if (node.init()) {
      node.tag = 1999;
      return node;
    }
    
    return null;
  }

  @override
  bool init() {
    if (super.init()) {
      initGroupingBehavior(this);
    }
    
    return true;
  }

  void configure(Ranger.BaseNode mainLayer) {
    // The GameLayer is required because we are emitting particles onto
    // that layer. The particles need to be emitted onto an independent
    // layer otherwise then would be in sync with the ship. This concept
    // is identical to the physical world.
    _mainLayer = mainLayer;
    
    _build();
    
    _thrust.maxMagnitude = MAX_THRUST_MAGNITUDE;
    _momentum.maxMagnitude = MAX_MAGNITUDE;
    
    _configureExhaust();
    
    _configureGun();
    
    // Default to +X axis
    directionByDegrees = 0.0;
  }
  
  set directionByDegrees(double angle) {
    //----------------------------------------------------------------
    // Default the momentum and thrust to the same angle.
    //----------------------------------------------------------------
    this.angle = thrustAngle = rotationByDegrees = angle;

    _momentum.directionByDegrees = this.angle;
    
    _thrust.directionByDegrees = thrustAngle;
    
    if (_exhaustPS != null)
      // Why is the exhaust particles' direction opposite that of the thrust?
      // Because the thrust is a vector in the direction of the ship (aka additive).
      _exhaustPS.particleActivation.angleDirection = _thrust.asAngleInDegrees + 180.0;
    if (gunPS != null)
      gunPS.particleActivation.angleDirection = _thrust.asAngleInDegrees;
  }

  // -----------------------------------------------------------------
  // Construct Gun and Particles
  // -----------------------------------------------------------------
  void _configureGun() {
    gunPS = new Ranger.BasicParticleSystem.initWith(5);

    gunPS.setPosition(motionPosition.x, motionPosition.y);
    
    Ranger.RandomValueParticleActivator pa = _configureForGunActivation(Ranger.Color4IWhite, Ranger.Color4IBlue);
    pa.angleDirection = _thrust.asAngleInDegrees;
    pa.angleVariance = 0.0;
    
    gunPS.particleActivation = pa;

    // Construct Gun Particles
    _populateParticleSystemWithCircles(gunPS);
    gunPS.active = true;
    
    // #### Debug visual BEGIN
    //Ranger.ParticleSystemVisual visual = _gunPS.emitterVisual;
    //visual.size = 10.0;
    //_gameLayer.addChild(visual, 200, 5001);
    // #### END
    
    _gunPort.setPosition(1.0, 0.0);
    _gunPort.visible = false;
    addChild(_gunPort, 202, 5003);
  }
  
  Ranger.ParticleActivation _configureForGunActivation(Ranger.Color4<int> fromColor, Ranger.Color4<int> toColor) {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    // They all live for the same amount of time.
    pa.lifespan.min = 0.0;
    pa.lifespan.max = 2.0;
    pa.lifespan.clampVarianceTo(Ranger.Variance.CLAMP_TO_MAX);
    
    pa.activationData.velocity.setSpeedRange(0.0, 10.0);
    pa.activationData.velocity.limitMagnitude = false;
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
    pa.speed.clampVarianceTo(Ranger.Variance.CLAMP_TO_MAX);

    pa.acceleration.min = 0.0;
    pa.acceleration.max = 0.0;
    pa.acceleration.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
   
    pa.startScale.min = 3.0;
    pa.startScale.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    pa.endScale.min = 3.0;
    pa.endScale.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
    
    pa.startColor.setWith(fromColor);
    pa.endColor.setWith(toColor);
    return pa;
  }

  // -----------------------------------------------------------------
  // Construct Exhaust and Particles
  // -----------------------------------------------------------------
  void _configureExhaust() {
    
    _exhaustPS = new Ranger.BasicParticleSystem.initWith(40);
    _exhaustPS.setPosition(motionPosition.x, motionPosition.y);
    
    Ranger.RandomValueParticleActivator pa = _configureForExhaustActivation();
    pa.angleDirection = _thrust.asAngleInDegrees;
    pa.angleVariance = 50.0;
    
    _exhaustPS.particleActivation = pa;

    // Construct Exhaust Particles
    _populateParticleSystemWithCircles(_exhaustPS);
    _exhaustPS.active = true;
    
    // #### Debug visual BEGIN
    //Ranger.ParticleSystemVisual visual = _exhaustPS.emitterVisual;
    //visual.size = 10.0;
    //_gameLayer.addChild(visual, 200, 5001);
    // #### END
    
    // The port is where the particles are emitted from.
    _exhaustPort.setPosition(-1.0, 0.0);
    _exhaustPort.visible = false;
    //_exhaustPort.iconVisible = false;
    _exhaustPort.uniformScale = 1.0;
    addChild(_exhaustPort, 201, 5002);
  }
  
  Ranger.ParticleActivation _configureForExhaustActivation() {
    Ranger.RandomValueParticleActivator pa = new Ranger.RandomValueParticleActivator();
    pa.lifespan.min = 0.1;
    pa.lifespan.max = 1.0;
    pa.lifespan.variance = 0.5;
    
    pa.activationData.velocity.setSpeedRange(1.0, 3.0);
    pa.activationData.velocity.limitMagnitude = false;
    pa.speed.min = pa.activationData.velocity.minMagnitude;
    pa.speed.max = pa.activationData.velocity.maxMagnitude;
    pa.speed.variance = 1.0;

    pa.acceleration.min = 0.0;
    pa.acceleration.max = 0.0;
    pa.acceleration.clampVarianceTo(Ranger.Variance.CLAMP_TO_MIN);
   
    pa.startScale.min = 1.0;
    pa.startScale.max = 1.5;
    pa.startScale.variance = 0.5;
    
    pa.endScale.min = 6.0;
    pa.endScale.max = 6.5;
    pa.endScale.variance = 3.5;
    
    pa.startColor.setWith(Ranger.Color4ILightBlue);
    pa.endColor.setWith(Ranger.Color4INavyBlue);
    return pa;
  }


  void _build() {
    // The ship is initially pointed down the +X axis.
    polygon = new Ranger.CustomPolygon.basic();
    polygon.points.add(new Vector2(1.0, 0.0));
    polygon.points.add(new Vector2(0.2, 0.5));
    polygon.points.add(new Vector2(-1.0, 0.5));
    polygon.points.add(new Vector2(-1.0, -0.5));
    polygon.points.add(new Vector2(0.2, -0.5));
    polygon.calcAABBox();

    Ranger.Color4<int> militaryGreen = Ranger.color4IFromHex("#6fa287");
    fillColor = militaryGreen;
    drawColor = Ranger.Color4IWhite;
    outlined = true;
  }
  
  void _populateParticleSystemWithCircles(Ranger.ParticleSystem ps) {
    // To populate a particle system we need prototypes to clone from.
    // Once the particle system has been built we can dispense with the
    // prototypes.
    
    // First we create a "prototype" visual which will be assigned to a
    // prototype particle.
    CircleParticleNode protoVisual = new CircleParticleNode.initWith(Ranger.Color4IBlack);
    protoVisual.tag = 8;
    protoVisual.visible = false;
    protoVisual.uniformScale = 1.0;
    
    // Next we create an actual particle and assign to it the prototype visual.
    // Together the particle system will clone this prototype particle along with its
    // visual (N) times.
    // Default values of 1.0 given because these values will determined when
    // the particle is launched. They are just place holder values for the
    // prototype.
    Ranger.UniversalParticle prototype = new Ranger.UniversalParticle.withNode(protoVisual);
    // These initial colors are often ignored in favor of what an Activator
    // will generate. So a generic black/white is supplied.
    prototype.initWithColor(Ranger.Color4IBlack, Ranger.Color4IWhite);
    prototype.initWithScale(1.0, 15.0);
    
    // Now we populate the particle system with "clones" of the prototype.
    // The particles will be emitted onto the main GameLayer.
    // If we had supplied "this" then the particles are emitted as children
    // of the ship and that would visually look incorrect, plus they
    // would inherit transform properties of the ship that we don't want.
    GameManager gm = GameManager.instance;

//    ps.addByPrototype(gm.zoomControl, prototype);
    ps.addByPrototype(gm.zoomControl, prototype);
    
    // The prototypes are no longer relevant as they have been cloned. So
    // we move it back to the pool. The other option is to NOT put them back
    // and free up resources.
    protoVisual.moveToPool();
    prototype.moveToPool();
  }

  @override
  void onEnter() {
    super.onEnter();
    

    // Because the ship needs to "watch" for state changes and has a particle
    // system, we need to schedule this node for clock ticks.
    scheduleUpdate();
  }
  
  @override
  void onExit() {
    super.onExit();
    unScheduleUpdate();
  }

//  @override
//  Vector2 get position => motionPosition;
//
//  @override
//  set position(Vector2 position) {
//    motionPosition.setFrom(position);
//  }

  @override
  void update(double dt) {
    if (_thrustOn) {
      GameManager gm = GameManager.instance;

      applyThrust();
      // Trigger another particle if one is available.
      _exhaustPS.activateByStyle(Ranger.ParticleActivation.VARIANCE_DIRECTIONAL);
    }
    
    // ------------------------
    // Pulse force
    // ------------------------
    if (_pulseOn) {
      _pulseDurationCount += dt;
      if (_pulseDurationCount > _pulseDuration) {
        _pulseOn = false;
        _pulseDurationCount = 0.0;
      }
      // Form a force vector and apply to ship's position
      _pulseForce.directionByDegrees = _pulseAngle;
      _pulseForce.magnitude = _pulseMag;
    }

    if (_pulseForce.speed > _pulseForce.minMagnitude) {
      _pulseForce.applyTo(motionPosition);
//      dirty = true;   // <--- You signal that the transform is dirty.
    }
    
    if (_pulseForce.speed > 0.0) {
      _pulseForce.decreaseSpeed(0.005);
    }

    if (_rotateCWOn && _rotateCCWOn) {
        // Rotating in both directions results in nothing.
    }
    else if (_rotateCWOn) {
        rotate(true);
        rotationByDegrees = angle;
    }
    else if (_rotateCCWOn) {
        rotate(false);
        rotationByDegrees = angle;
    }
    
    if (_thrust.speed > 0.0)
        _momentum.add(_thrust);
    
    // Now update the ship's position based on the momentum.
    if (_momentum.speed > 0.0) {
      _momentum.applyTo(motionPosition);
//      dirty = true;   // <--- You signal that the transform is dirty.
    }
    
    // If there is no thrust being applied then the thrust slowly dies off.
    decreaseSpeed();
    
    // Update momentum if there is drag.
    _momentum.decreaseSpeed(0.01);

    // Map port to hud-space then to game-space.
    Vector2 gs = _convertToGameSpace(_exhaustPort.position);
    
    _exhaustPS.setPosition(gs.x, gs.y);
    
    gs = _convertToGameSpace(_gunPort.position);
    gunPS.setPosition(gs.x, gs.y);

    if (_firing) {
      _firing = false;
      gunPS.activateByStyle(Ranger.ParticleActivation.UNI_DIRECTIONAL);
    }
    
    _exhaustPS.update(dt);
    gunPS.update(dt);
  }
  
  Vector2 _convertToGameSpace(Vector2 location) {
    GameManager gm = GameManager.instance;
    Ranger.Vector2P worldS = convertToWorldSpace(location);
    Ranger.Vector2P gs = gm.zoomControl.convertWorldToNodeSpace(worldS.v);

    // Clean up.
    worldS.moveToPool();
    gs.moveToPool();
    
    // It is okay to return ns.v because it only been returned to
    // the pool. Of course the callie shouldn't hold it permanently
    // either.
    return gs.v;
  }
  
  void rotate(bool direction) {
    if (direction) {
      // CW
      angle += angularSpeed;
      if (angle > 360.0)
        angle -= 360.0;
    } else {
      // CCW
      angle -= angularSpeed;
      if (angle < 0.0)
        angle += 360.0;
    }
    
    _thrust.directionByDegrees = angle;
    
    _exhaustPS.particleActivation.angleDirection = _thrust.asAngleInDegrees + 180.0;
    gunPS.particleActivation.angleDirection = _thrust.asAngleInDegrees;
  }
  
  void rotateCWOn() {
    _rotateCWOn = true;
  }
  
  void rotateCWOff() {
    _rotateCWOn = false;
  }
  
  void rotateCCWOn() {
    _rotateCCWOn = true;
  }
  
  void rotateCCWOff() {
    _rotateCCWOn = false;
  }
  
  void setSpeed(double speed) {
    _thrust.speed = speed;
  }
  
  void increaseSpeed([double scale]) {
    if (scale != null)
      _thrust.increaseSpeed(0.005 * scale);
    else
      _thrust.increaseSpeed(0.005);
  }
  
  void decreaseSpeed() {
    _thrust.decreaseSpeed(0.002);
  }
  
  void pulseForceFrom(double duration, double angle, double mag) {
    _pulseOn = true;
    _pulseDuration = duration;
    _pulseAngle = angle;
    _pulseMag = mag;
  }
  
  void applyThrust([double scale]) {
    // As thrust is being applied the speed increases but only to a maximum.
    increaseSpeed(scale);
  }
  
  void thrust(bool onOff) {
    if (onOff) {
      // Thrust on
      _thrust.speed = 0.025;
      _thrustOn = true;
    } else {
      // Thrust off
      _thrust.speed = 0.0;
      _thrustOn = false;
    }
  }

  void fire(bool onOff) {
    if (onOff) {
      // Firing.
      _firing = true;
    } else {
      // Stop firing.
      _firing = false;
    }
  }

}
