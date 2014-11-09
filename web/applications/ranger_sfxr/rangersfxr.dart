library rangersfxr;

import 'dart:html';
import 'dart:math' as Math;
import 'dart:typed_data'; // for Float32List
import 'dart:web_audio';  // for WebAudio
import 'dart:convert';    // for JSON

// -------------------------------------------------------------
// Sound/Audio
// -------------------------------------------------------------
part 'audio/sfxr.dart';
part 'audio/generator.dart';
part 'audio/param_view.dart';
part 'audio/external_view.dart';
part 'audio/internal_view.dart';
part 'audio/wave.dart';
part 'audio/sound_utilities.dart';

part 'widgets/slider.dart';

Sfxr _sfxr;
int _nameCount = 0;
AudioContext context = new AudioContext();
InputElement _btnHiddenFileElement;
bool _processedFile = false;

Slider _AttackSlider;
Slider _SustainSlider;
Slider _SustainPunchSlider;
Slider _DecaySlider;

Slider _StartFreqSlider;
Slider _MinCutoffSlider;
Slider _SlideSlider;
Slider _DeltaSlideSlider;

Slider _DepthSlider;
Slider _SpeedSlider;

Slider _FreqMultSlider;
Slider _ChangeSpeedSlider;

Slider _DutyCycleSlider;
Slider _SweepSlider;

Slider _RetriggerRateSlider;

Slider _FlangerOffsetSlider;
Slider _FlangerSweepSlider;

Slider _LowPassCutoffSlider;
Slider _LowPassSweepSlider;
Slider _LowPassResonanceSlider;

Slider _HighPassCutoffSlider;
Slider _HighPassSweepSlider;

Slider _GainSlider;

void main() {
  
  querySelector("#btnPickUpCoin").onClick.listen((Event e) => _pickupCoin(e));
  querySelector("#btnLaserShoot").onClick.listen((Event e) => _laserShoot(e));
  querySelector("#btnExplosion").onClick.listen((Event e) => _explosion(e));
  querySelector("#btnPowerUp").onClick.listen((Event e) => _powerUp(e));
  querySelector("#btnHitHurt").onClick.listen((Event e) => _hitHurt(e));
  querySelector("#btnJump").onClick.listen((Event e) => _jump(e));
  querySelector("#btnBlipSelect").onClick.listen((Event e) => _blipSelect(e));
  querySelector("#btnRandom").onClick.listen((Event e) => _random(e));
  querySelector("#btnTone").onClick.listen((Event e) => _tone(e));
  querySelector("#btnMutate").onClick.listen((Event e) => _mutate(e));

  querySelector("#btnSineWave").onClick.listen((Event e) => _sine(e));
  querySelector("#btnSquareWave").onClick.listen((Event e) => _square(e));
  querySelector("#btnSawtoothWave").onClick.listen((Event e) => _sawtooth(e));
  querySelector("#btnNoiseWave").onClick.listen((Event e) => _whiteNoise(e));
  querySelector("#btnPinkNoiseWave").onClick.listen((Event e) => _pinkNoise(e));
  querySelector("#btnBrownNoiseWave").onClick.listen((Event e) => _brownNoise(e));
  
  querySelector("#btnPlay").onClick.listen((Event e) => _play(e));
  querySelector("#btnDumpSamples").onClick.listen((Event e) => _dump(e));
  querySelector("#btnDumpSettings").onClick.listen((Event e) => _dumpAsSettings(e));
  
  querySelector("#btnDesktopOpen").onClick.listen((Event e) => _getDesktopFile());
  //querySelector("#btnCopyToClipboard").onClick.listen((Event e) => _copyToClipboard());
  querySelector("#btnGenWave").onClick.listen((Event e) => _generateWav());
  
  _AttackSlider = new Slider.basic(
      querySelector("#attackTimeId"), querySelector("#attackTimeView"), 
      _attackChange, _attackSlide);
  _SustainSlider = new Slider.basic(
      querySelector("#sustainTimeId"), querySelector("#sustainTimeView"), 
      _sustainChange, _sustainSlide);
  _SustainPunchSlider = new Slider.basic(
      querySelector("#sustainPunchId"), querySelector("#sustainPunchView"), 
      _sustainPunchChange, _sustainPunchSlide);
  _DecaySlider = new Slider.basic(
      querySelector("#DecayTimeId"), querySelector("#DecayTimeView"), 
      _decayChange, _decaySlide);

  _StartFreqSlider = new Slider.basic(
      querySelector("#startFreqId"), querySelector("#startFreqView"), 
      _startFreqChange, _startFreqSlide);
  _MinCutoffSlider = new Slider.basic(
      querySelector("#minCutoffId"), querySelector("#minCutoffView"), 
      _minCutoffChange, _minCutoffSlide);
  _SlideSlider = new Slider.basic(
      querySelector("#slideId"), querySelector("#slideView"), 
      _slideChange, _slideSlide);
  _DeltaSlideSlider = new Slider.basic(
      querySelector("#deltaSlideId"), querySelector("#deltaSlideView"), 
      _deltaSlideChange, _deltaSlideSlide);

  _DepthSlider = new Slider.basic(
      querySelector("#depthId"), querySelector("#depthView"), 
      _depthChange, _depthSlide);
  _SpeedSlider = new Slider.basic(
      querySelector("#speedId"), querySelector("#speedView"), 
      _speedChange, _speedSlide);

  _FreqMultSlider = new Slider.basic(
      querySelector("#freqMultId"), querySelector("#freqMultView"), 
      _freqMultChange, _freqMultSlide);
  _ChangeSpeedSlider = new Slider.basic(
      querySelector("#changeSpeedId"), querySelector("#changeSpeedView"), 
      _changeSpeedChange, _changeSpeedSlide);

  _DutyCycleSlider = new Slider.basic(
      querySelector("#dutyCycleId"), querySelector("#dutyCycleView"), 
      _dutyCycleChange, _dutyCycleSlide);
  _SweepSlider = new Slider.basic(
      querySelector("#sweepId"), querySelector("#sweepView"), 
      _sweepChange, _sweepSlide);

  _RetriggerRateSlider = new Slider.basic(
      querySelector("#retriggerRateId"), querySelector("#retriggerRateView"), 
      _retriggerRateChange, _retriggerRateSlide);

  _FlangerOffsetSlider = new Slider.basic(
      querySelector("#flangerOffsetId"), querySelector("#flangerOffsetView"), 
      _flangerOffsetChange, _flangerOffsetSlide);
  _FlangerSweepSlider = new Slider.basic(
      querySelector("#flangerSweepId"), querySelector("#flangerSweepView"), 
      _flangerSweepChange, _flangerSweepSlide);

  _LowPassCutoffSlider = new Slider.basic(
      querySelector("#lpCutoffFreqId"), querySelector("#lpCutoffFreqView"), 
      _lpCutoffFreqChange, _lpCutoffFreqSlide);
  _LowPassSweepSlider = new Slider.basic(
      querySelector("#lpCutoffSweepId"), querySelector("#lpCutoffSweepView"), 
      _lpCutoffSweepChange, _lpCutoffSweepSlide);
  _LowPassResonanceSlider = new Slider.basic(
      querySelector("#lpResonanceId"), querySelector("#lpResonanceView"), 
      _lpResonanceChange, _lpResonanceSlide);

  _HighPassCutoffSlider = new Slider.basic(
      querySelector("#hpCutoffFreqId"), querySelector("#hpCutoffFreqView"), 
      _hpCutoffFreqChange, _hpCutoffFreqSlide);
  _HighPassSweepSlider = new Slider.basic(
      querySelector("#hpCutoffSweepId"), querySelector("#hpCutoffSweepView"), 
      _hpCutoffSweepChange, _hpCutoffSweepSlide);
  
  _GainSlider = new Slider.basic(
      querySelector("#soundVolumeId"), querySelector("#gainView"), 
      _soundVolumeChange, _soundVolumeSlide);
  
  _btnHiddenFileElement = querySelector("#fileElem");
  
  _sfxr = new Sfxr.basic(context);
  
  //_tone(null);
  //_updateView(true);
}

void _updateView([bool loading = false]) {
  _sfxr.convert();

  _AttackSlider.text = _sfxr.uiView.attack.toStringAsFixed(3);
  _SustainSlider.text = _sfxr.uiView.sustain.toStringAsFixed(3);
  _SustainPunchSlider.text = _sfxr.uiView.punch.toStringAsFixed(3);
  _DecaySlider.text = _sfxr.uiView.decay.toStringAsFixed(3);
  
  _StartFreqSlider.text = _sfxr.uiView.frequency.toStringAsFixed(1);
  _MinCutoffSlider.text = _sfxr.uiView.frequencyMin.toStringAsFixed(3);
  _SlideSlider.text = _sfxr.uiView.frequencySlide.toStringAsFixed(3);
  _DeltaSlideSlider.text = _sfxr.uiView.frequencySlideSlide.toStringAsFixed(6);

  _DepthSlider.text = _sfxr.uiView.vibratoDepth.toStringAsFixed(6);
  _SpeedSlider.text = _sfxr.uiView.vibratoRate.toStringAsFixed(6);

  _FreqMultSlider.text = _sfxr.uiView.arpeggioFactor.toStringAsFixed(3);
  _ChangeSpeedSlider.text = _sfxr.uiView.arpeggioDelay.toStringAsFixed(4);

  _DutyCycleSlider.text = _sfxr.uiView.dutyCycle.toStringAsFixed(2);
  _SweepSlider.text = _sfxr.uiView.dutyCycleSweep.toStringAsFixed(3);

  _RetriggerRateSlider.text = _sfxr.uiView.retriggerRate.toStringAsFixed(2);

  _FlangerOffsetSlider.text = _sfxr.uiView.flangerOffset.toStringAsFixed(2);
  _FlangerSweepSlider.text = _sfxr.uiView.flangerSweep.toStringAsFixed(2);

  _LowPassCutoffSlider.text = _sfxr.uiView.lowPassFrequency.toStringAsFixed(0);
  _LowPassSweepSlider.text = _sfxr.uiView.lowPassSweep.toStringAsFixed(5);
  _LowPassResonanceSlider.text = _sfxr.uiView.lowPassResonance.toStringAsFixed(2);

  _HighPassCutoffSlider.text = _sfxr.uiView.highPassFrequency.toStringAsFixed(0);
  _HighPassSweepSlider.text = _sfxr.uiView.highPassSweep.toStringAsFixed(9);
  
  _GainSlider.text = _sfxr.uiView.gain.toStringAsFixed(2);

  _resetGenTextStyles();
  _resetOscTextStyles();
  
  _selectOscillator(_sfxr.view.waveShape);
  _selectGenerator(_sfxr.category);
  
  if (loading) {
    _AttackSlider.doubleValue = _sfxr.view.attack;
    _SustainSlider.doubleValue = _sfxr.view.sustain;
    _SustainPunchSlider.doubleValue = _sfxr.view.punch;
    _DecaySlider.doubleValue = _sfxr.view.decay;
    
    _StartFreqSlider.doubleValue = _sfxr.view.p_base_freq;
    _MinCutoffSlider.doubleValue = _sfxr.view.p_freq_limit;
    _SlideSlider.doubleValue = _sfxr.view.p_freq_ramp;
    _DeltaSlideSlider.doubleValue = _sfxr.view.p_freq_dramp;

    _DepthSlider.doubleValue = _sfxr.view.p_vib_strength;
    _SpeedSlider.doubleValue = _sfxr.view.p_vib_speed;

    _FreqMultSlider.doubleValue = _sfxr.view.p_arp_mod;
    _ChangeSpeedSlider.doubleValue = _sfxr.view.p_arp_speed;

    _DutyCycleSlider.doubleValue = _sfxr.view.p_duty;
    _SweepSlider.doubleValue = _sfxr.view.p_duty_ramp;

    _RetriggerRateSlider.doubleValue = _sfxr.view.p_repeat_speed;

    _FlangerOffsetSlider.doubleValue = _sfxr.view.p_pha_offset;
    _FlangerSweepSlider.doubleValue = _sfxr.view.p_pha_ramp;

    _LowPassCutoffSlider.doubleValue = _sfxr.view.p_lpf_freq;
    _LowPassSweepSlider.doubleValue = _sfxr.view.p_lpf_ramp;
    _LowPassResonanceSlider.doubleValue = _sfxr.view.p_lpf_resonance;
    
    _HighPassCutoffSlider.doubleValue = _sfxr.view.p_hpf_freq;
    _HighPassSweepSlider.doubleValue = _sfxr.view.p_hpf_ramp;
    
    _GainSlider.doubleValue = _sfxr.view.sound_vol;
  }
}

// -----------------------------------------------------------------
// Envelope
// -----------------------------------------------------------------
void _attackChange() {
  _sfxr.view.attack = _AttackSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _attackSlide() {
  _sfxr.view.attack = _AttackSlider.doubleValue;
  _updateView();
}

void _sustainChange() {
  _sfxr.view.sustain = _SustainSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _sustainSlide() {
  _sfxr.view.sustain = _SustainSlider.doubleValue;
  _updateView();
}

void _sustainPunchChange() {
  _sfxr.view.punch = _SustainPunchSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _sustainPunchSlide() {
  _sfxr.view.punch = _SustainPunchSlider.doubleValue;
  _updateView();
}

void _decayChange() {
  _sfxr.view.decay = _DecaySlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _decaySlide() {
  _sfxr.view.decay = _DecaySlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Envelope
// -----------------------------------------------------------------
void _startFreqChange() {
  _sfxr.view.p_base_freq = _StartFreqSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _startFreqSlide() {
  _sfxr.view.p_base_freq = _StartFreqSlider.doubleValue;
  _updateView();
}

void _minCutoffChange() {
  _sfxr.view.p_freq_limit = _MinCutoffSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _minCutoffSlide() {
  _sfxr.view.p_freq_limit = _MinCutoffSlider.doubleValue;
  _updateView();
}

void _slideChange() {
  _sfxr.view.p_freq_ramp = _SlideSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _slideSlide() {
  _sfxr.view.p_freq_ramp = _SlideSlider.doubleValue;
  _updateView();
}

void _deltaSlideChange() {
  _sfxr.view.p_freq_dramp = _DeltaSlideSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _deltaSlideSlide() {
  _sfxr.view.p_freq_dramp = _DeltaSlideSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Vibrato
// -----------------------------------------------------------------
void _depthChange() {
  _sfxr.view.p_vib_strength = _DepthSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _depthSlide() {
  _sfxr.view.p_vib_strength = _DepthSlider.doubleValue;
  _updateView();
}

void _speedChange() {
  _sfxr.view.p_vib_speed = _SpeedSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _speedSlide() {
  _sfxr.view.p_vib_speed = _SpeedSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Arpeggiation
// -----------------------------------------------------------------
void _freqMultChange() {
  _sfxr.view.p_arp_mod = _FreqMultSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _freqMultSlide() {
  _sfxr.view.p_arp_mod = _FreqMultSlider.doubleValue;
  _updateView();
}

void _changeSpeedChange() {
  _sfxr.view.p_arp_speed = _ChangeSpeedSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _changeSpeedSlide() {
  _sfxr.view.p_arp_speed = _ChangeSpeedSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Duty Cycle
// -----------------------------------------------------------------
void _dutyCycleChange() {
  _sfxr.view.p_duty = _DutyCycleSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _dutyCycleSlide() {
  _sfxr.view.p_duty = _DutyCycleSlider.doubleValue;
  _updateView();
}

void _sweepChange() {
  _sfxr.view.p_duty_ramp = _SweepSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _sweepSlide() {
  _sfxr.view.p_duty_ramp = _SweepSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Retrigger
// -----------------------------------------------------------------
void _retriggerRateChange() {
  _sfxr.view.p_repeat_speed = _RetriggerRateSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _retriggerRateSlide() {
  _sfxr.view.p_repeat_speed = _RetriggerRateSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Flanger
// -----------------------------------------------------------------
void _flangerOffsetChange() {
  double v = _FlangerOffsetSlider.doubleValue;
  _sfxr.view.p_pha_offset = v;//(v < 0.0 ? -1.0 : 1.0) * Math.pow(v , 2.0) * 1020.0;
  _sfxr.update();
  _sfxr.play();
}

void _flangerOffsetSlide() {
  double v = _FlangerOffsetSlider.doubleValue;
  _sfxr.view.p_pha_offset = v;//(v < 0.0 ? -1.0 : 1.0) * Math.pow(v , 2.0) * 1020.0;
  _updateView();
}

void _flangerSweepChange() {
  double v = _FlangerSweepSlider.doubleValue;
  _sfxr.view.p_pha_ramp = v;//(v < 0.0 ? -1.0 : 1.0) * Math.pow(v , 2.0);
  _sfxr.update();
  _sfxr.play();
}

void _flangerSweepSlide() {
  double v = _FlangerSweepSlider.doubleValue;
  _sfxr.view.p_pha_ramp = v;//(v < 0.0 ? -1.0 : 1.0) * Math.pow(v , 2.0);
  _updateView();
}

// -----------------------------------------------------------------
// Low pass
// -----------------------------------------------------------------
void _lpCutoffFreqChange() {
  _sfxr.view.p_lpf_freq = _LowPassCutoffSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _lpCutoffFreqSlide() {
  _sfxr.view.p_lpf_freq = _LowPassCutoffSlider.doubleValue;
  _updateView();
}

void _lpCutoffSweepChange() {
  _sfxr.view.p_lpf_ramp = _LowPassSweepSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _lpCutoffSweepSlide() {
  _sfxr.view.p_lpf_ramp = _LowPassSweepSlider.doubleValue;
  _updateView();
}

void _lpResonanceChange() {
  _sfxr.view.p_lpf_resonance = _LowPassResonanceSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _lpResonanceSlide() {
  _sfxr.view.p_lpf_resonance = _LowPassResonanceSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// High pass
// -----------------------------------------------------------------
void _hpCutoffFreqChange() {
_sfxr.view.p_hpf_freq = _HighPassCutoffSlider.doubleValue;
_sfxr.update();
_sfxr.play();
}

void _hpCutoffFreqSlide() {
_sfxr.view.p_hpf_freq = _HighPassCutoffSlider.doubleValue;
_updateView();
}

void _hpCutoffSweepChange() {
_sfxr.view.p_hpf_ramp = _HighPassSweepSlider.doubleValue;
_sfxr.update();
_sfxr.play();
}

void _hpCutoffSweepSlide() {
_sfxr.view.p_hpf_ramp = _HighPassSweepSlider.doubleValue;
_updateView();
}

// -----------------------------------------------------------------
// Gain
// -----------------------------------------------------------------
void _soundVolumeChange() {
  _sfxr.soundVolume = _GainSlider.doubleValue;
  _sfxr.update();
  _sfxr.play();
}

void _soundVolumeSlide() {
  _sfxr.soundVolume = _GainSlider.doubleValue;
  _updateView();
}

void _sine(Event e) {
  _resetOscTextStyles();
  _selectSine();
  _sfxr.updateByWaveShape(Generator.SINE);
  _sfxr.play();
}

void _square(Event e) {
  _resetOscTextStyles();
  _selectSquare();
  _sfxr.updateByWaveShape(Generator.SQUARE);
  _sfxr.play();
}

void _sawtooth(Event e) {
  _resetOscTextStyles();
  _selectSawtooth();
  _sfxr.updateByWaveShape(Generator.SAWTOOTH);
  _sfxr.play();
}

void _whiteNoise(Event e) {
  _resetOscTextStyles();
  _selectNoise();
  _sfxr.updateByWaveShape(Generator.NOISE);
  _sfxr.play();
}

void _pinkNoise(Event e) {
  _resetOscTextStyles();
  _selectPink();
  _sfxr.updateByWaveShape(Generator.NOISE_PINK);
  _sfxr.play();
}

void _brownNoise(Event e) {
  _resetOscTextStyles();
  _selectBrown();
  _sfxr.updateByWaveShape(Generator.NOISE_BROWNIAN);
  _sfxr.play();
}

void _resetOscTextStyles() {
  querySelector("#sineText").style.color ="#ffffff";
  querySelector("#squareText").style.color ="#ffffff";
  querySelector("#sawtoothText").style.color ="#ffffff";
  querySelector("#whiteText").style.color ="#ffffff";
  querySelector("#pinkText").style.color ="#ffffff";
  querySelector("#brownText").style.color ="#ffffff";
}

void _selectSquare() {
  querySelector("#squareText").style.color ="#22ccff";
  querySelector("#dutyTitle").style.color ="#ffffff";
  _DutyCycleSlider.disable = false;
  _SweepSlider.disable= false;
}
void _selectSawtooth() {
  querySelector("#sawtoothText").style.color ="#22ccff";
  querySelector("#dutyTitle").style.color ="#ffffff";
  _DutyCycleSlider.disable = false;
  _SweepSlider.disable= false;
}
void _selectSine() {
  querySelector("#sineText").style.color ="#22ccff";
  querySelector("#dutyTitle").style.color ="#aaaaaa";
  _DutyCycleSlider.disable = true;
  _SweepSlider.disable= true;
}
void _selectNoise() {
  querySelector("#whiteText").style.color ="#22ccff";
  querySelector("#dutyTitle").style.color ="#aaaaaa";
  _DutyCycleSlider.disable = true;
  _SweepSlider.disable= true;
}
void _selectPink() {
  querySelector("#pinkText").style.color ="#22ccff";
  querySelector("#dutyTitle").style.color ="#aaaaaa";
  _DutyCycleSlider.disable = true;
  _SweepSlider.disable= true;
}
void _selectBrown() {
  querySelector("#brownText").style.color ="#22ccff";
  querySelector("#dutyTitle").style.color ="#aaaaaa";
  _DutyCycleSlider.disable = true;
  _SweepSlider.disable= true;
}

void _play(Event e) {
  _sfxr.play();
}

void _dump(Event e) {
  Map m = _sfxr.toMapAsSamples(_sfxr.current, _sfxr.category);
  print(JSON.encode(m));
}

void _dumpAsSettings(Event e) {
  // Settings + Noise buffer
  Map m = _sfxr.toMapAsSettings(_sfxr.current, _sfxr.category);
  //print(JSON.encode(m));
  TextAreaElement area = querySelector("#dataId");
  area.text = JSON.encode(m);
  _copyToClipboard();
}

void _pickupCoin(Event e) {
  _resetGenTextStyles();
  _selectPickup();
  String name = "PickupCoint${_nameCount++}";
  _sfxr.autoGenByCategory(name, {"Category": Sfxr.PICKUP_COIN});
  _resetOscTextStyles();
  _selectOscillator(_sfxr.view.waveShape);
  _sfxr.play();
}

void _laserShoot(Event e) {
  _resetGenTextStyles();
  _selectLaser();
  String name = "LaserShoot${_nameCount++}";
  _sfxr.autoGenByCategory(name, {"Category": Sfxr.LASER_SHOOT});
  _resetOscTextStyles();
  _selectOscillator(_sfxr.view.waveShape);
  _updateView(true);
  _sfxr.play();
}

void _explosion(Event e) {
  _resetGenTextStyles();
  _selectExplode();
  String name = "Explosion${_nameCount++}";
  _sfxr.autoGenByCategory(name, {"Category": Sfxr.EXPLOSION, "NoiseType": ""});
  _resetOscTextStyles();
  _selectOscillator(_sfxr.view.waveShape);
  _updateView(true);
  _sfxr.play();
}

void _powerUp(Event e) {
  _resetGenTextStyles();
  _selectPower();
  String name = "PowerUp${_nameCount++}";
  _sfxr.autoGenByCategory(name, {"Category": Sfxr.POWERUP});
  _resetOscTextStyles();
  _selectOscillator(_sfxr.view.waveShape);
  _updateView(true);
  _sfxr.play();
}

void _hitHurt(Event e) {
  _resetGenTextStyles();
  _selectHitHurt();
  String name = "HitHurt${_nameCount++}";
  _sfxr.autoGenByCategory(name, {"Category": Sfxr.HIT_HURT});
  _resetOscTextStyles();
  _selectOscillator(_sfxr.view.waveShape);
  _updateView(true);
  _sfxr.play();
}

void _jump(Event e) {
  _resetGenTextStyles();
  _selectJump();
  String name = "Jump${_nameCount++}";
  _sfxr.autoGenByCategory(name, {"Category": Sfxr.JUMP});
  _resetOscTextStyles();
  _selectOscillator(_sfxr.view.waveShape);
  _updateView(true);
  _sfxr.play();
}

void _blipSelect(Event e) {
  _resetGenTextStyles();
  _selectBlip();
  String name = "BlipSelect${_nameCount++}";
  _sfxr.autoGenByCategory(name, {"Category": Sfxr.BLIP_SELECT});
  _resetOscTextStyles();
  _selectOscillator(_sfxr.view.waveShape);
  _updateView(true);
  _sfxr.play();
}

void _random(Event e) {
  _resetGenTextStyles();
  _selectRandom();
  
  String name = "Tone${_nameCount++}";
  _sfxr.autoGenByCategory(name, {"Category": Sfxr.RANDOM});

  _resetOscTextStyles();
  _selectOscillator(_sfxr.view.waveShape);
  
  _updateView(true);
  
  _sfxr.play();
}

void _tone(Event e) {
  _resetGenTextStyles();
  _selectTone();
  
  String name = "Tone${_nameCount++}";
  _sfxr.autoGenByCategory(name, {"Category": Sfxr.TONE});

  _updateView(true);
  
  _sfxr.play();
}

void _mutate(Event e) {
  _sfxr.mutate();
  _updateView(true);
  _sfxr.play();
}

void _resetGenTextStyles() {
  querySelector("#pickupText").style.color ="#ffffff";
  querySelector("#laserText").style.color ="#ffffff";
  querySelector("#explodeText").style.color ="#ffffff";
  querySelector("#powerText").style.color ="#ffffff";
  querySelector("#hitText").style.color ="#ffffff";
  querySelector("#jumpText").style.color ="#ffffff";
  querySelector("#blipText").style.color ="#ffffff";
  querySelector("#randomText").style.color ="#ffffff";
  querySelector("#toneText").style.color ="#ffffff";
}

void _selectPickup() {
  querySelector("#pickupText").style.color ="#44ffaa";
}
void _selectLaser() {
  querySelector("#laserText").style.color ="#44ffaa";
}
void _selectExplode() {
  querySelector("#explodeText").style.color ="#44ffaa";
}
void _selectPower() {
  querySelector("#powerText").style.color ="#44ffaa";
}
void _selectHitHurt() {
  querySelector("#hitText").style.color ="#44ffaa";
}
void _selectJump() {
  querySelector("#jumpText").style.color ="#44ffaa";
}
void _selectBlip() {
  querySelector("#blipText").style.color ="#44ffaa";
}
void _selectRandom() {
  querySelector("#randomText").style.color ="#44ffaa";
}
void _selectTone() {
  querySelector("#toneText").style.color ="#44ffaa";
}

void _selectOscillator(int waveShape) {
  switch (waveShape) {
    case Generator.SQUARE: _selectSquare(); return;
    case Generator.SAWTOOTH: _selectSawtooth(); return;
    case Generator.SINE: _selectSine(); return;
    case Generator.NOISE: _selectNoise(); return;
    case Generator.NOISE_PINK: _selectPink(); return;
    case Generator.NOISE_BROWNIAN: _selectBrown(); return;
  }
}

void _selectGenerator(String category) {
  if (category == Sfxr.PICKUP_COIN)
    _selectPickup();
  else if (category == Sfxr.LASER_SHOOT)
    _selectLaser();
  else if (category == Sfxr.EXPLOSION)
    _selectExplode();
  else if (category == Sfxr.POWERUP)
    _selectPower();
  else if (category == Sfxr.HIT_HURT)
    _selectHitHurt();
  else if (category == Sfxr.JUMP)
    _selectJump();
  else if (category == Sfxr.BLIP_SELECT)
    _selectBlip();
  else if (category == Sfxr.RANDOM)
    _selectRandom();
  else if (category == Sfxr.TONE)
    _selectTone();
}

void _copyToClipboard() {
  TextAreaElement area = querySelector("#dataId");
  area.focus();
  area.select();

  window.document.execCommand("copy", true, "");
}

void _generateWav() {
  Wave wav = _sfxr.generator.wave;
  AnchorElement a = querySelector("#wavId");
  a.href = wav.dataURI;
  a.text = "${_sfxr.current}";
  a.style.visibility = "visible";
}

// -------------------------------------------------------------------
// Desktop files
//     <input type="file" id="fileElem" style="display: none;">    
// -------------------------------------------------------------------
// This handles the click on the DIV
void _getDesktopFile() {
  _processedFile = false;
  
  _btnHiddenFileElement.onChange.listen((Event e) {
    if (!_processedFile)
      _loadFile();
  });

  _btnHiddenFileElement.click();
}

void _loadFile() {
  _processedFile = true;
  
  File file = _btnHiddenFileElement.files.first;

  final FileReader reader = new FileReader();
  
  reader.onLoad.listen((Event e) {
    String sMap = reader.result as String;
    Map m = JSON.decode(sMap);
    _sfxr = new Sfxr.withJSON(m, context);
    
    _updateView(true);

    _sfxr.play();
  });
  
  reader.readAsText(file);
}