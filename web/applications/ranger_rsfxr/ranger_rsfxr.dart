library ranger_rsfxr;

import 'dart:html';
import 'dart:web_audio';  // for WebAudio
import 'dart:convert';    // for JSON

import 'package:ranger/ranger.dart' as Ranger;

// - add bit crusher, include a checkbox for Buffered. <--- ScriptNode broken
//   bit crusher could be done as a AudioBufferSourceNode.
// - add local-storage for 5 presets
// - Distortion together with Noise tends to crash the app.

part 'widgets/slider.dart';
part 'widgets/channel_widget.dart';

int _nameCount = 0;

InputElement _btnHiddenFileElement;
bool _processedFile = false;

Slider _AttackSlider;
Slider _DecaySlider;
Slider _SustainSlider;
Slider _ReleaseSlider;

Slider _StartFreqSlider;
Slider _MinCutoffSlider;
Slider _SlideSlider;
Slider _DeltaSlideSlider;
Slider _FreqGainSlider;

Slider _VibratoDepthSlider;
Slider _VibratoSpeedSlider;

Slider _TremoloDepthSlider;
Slider _TremoloSpeedSlider;

Slider _ArpeFreqStepSlider;
Slider _ArpeTimeStepSlider;
Slider _ArpeExpoDecaySlider;
Slider _ArpeNotesSlider;

Slider _DutyCycleSlider;
Slider _SweepSlider;

Slider _RetriggerCountSlider;
Slider _RetriggerRateSlider;

Slider _FlangerFreqSlider;
Slider _FlangerDelaySlider;
Slider _FlangerFeedbackSlider;
Slider _FlangerFeedbackSweepSlider;
Slider _FlangerBaseDelaySlider;

Slider _LowPassCutoffSlider;
Slider _LowPassSweepSlider;
Slider _LowPassResonanceSlider;

Slider _HighPassCutoffSlider;
Slider _HighPassSweepSlider;
Slider _HighPassResonanceSlider;

Slider _NoisePlaybackRateSlider;
Slider _NoiseBufferSizeSlider;
Slider _NoiseVolumeSlider;
Slider _NoiseOverdriveSlider;

Slider _DistortionScaleSlider;
Slider _DistortionPartsSlider;
Slider _DistortionMag1Slider;
Slider _DistortionMag2Slider;
Slider _DistortionMag3Slider;
Slider _DistortionEquationSlider;
Slider _DistortionClampSlider;

Slider _GainSlider;

Ranger.AudioMixer _audioMixer;
List<ChannelWidget> _channelWidgets = new List<ChannelWidget>();

void main() {
  
  _audioMixer = new Ranger.AudioMixer.basic(new AudioContext());
  
  DivElement channels = querySelector("#channelsContainerId");
  
  bool even = false;
  for (int i = 0; i < Ranger.AudioMixer.MAX_CHANNELS; i++) {
    ChannelWidget cw = new ChannelWidget.basic();
    _channelWidgets.add(cw);
    if (i == 0)
      cw.setActive();
    cw.callback = _channelsCallback;
    if (even)
      cw.container.classes.add("channelRowE");
    else
      cw.container.classes.add("channelRowO");
    channels.append(cw.container);
    even = !even;
  }
  
  querySelector("#btnPickUpCoin").onClick.listen((Event e) => _pickupCoin(e));
  querySelector("#btnLaserShoot").onClick.listen((Event e) => _laserShoot(e));
  querySelector("#btnExplosion").onClick.listen((Event e) => _explosion(e));
  querySelector("#btnPowerUp").onClick.listen((Event e) => _powerUp(e));
  querySelector("#btnHitHurt").onClick.listen((Event e) => _hitHurt(e));
  querySelector("#btnJump").onClick.listen((Event e) => _jump(e));
  querySelector("#btnBlipSelect").onClick.listen((Event e) => _blipSelect(e));
  querySelector("#btnAlienShips").onClick.listen((Event e) => _alienShips(e));
  querySelector("#btnHighAlarms").onClick.listen((Event e) => _highAlarms(e));
  querySelector("#btnLowAlarms").onClick.listen((Event e) => _lowAlarms(e));
  querySelector("#btnRandom").onClick.listen((Event e) => _random(e));
  querySelector("#btnTone").onClick.listen((Event e) => _tone(e));
  querySelector("#btnMutate").onClick.listen((Event e) => _mutate(e));

  querySelector("#btnSineWave").onClick.listen((Event e) => _sine(e));
  querySelector("#btnSquareWave").onClick.listen((Event e) => _square(e));
  querySelector("#btnSawtoothWave").onClick.listen((Event e) => _sawtooth(e));
  querySelector("#btnTriangleWave").onClick.listen((Event e) => _triangle(e));
  querySelector("#btnNoiseWave").onClick.listen((Event e) => _whiteNoise(e));
  querySelector("#btnPinkNoiseWave").onClick.listen((Event e) => _pinkNoise(e));
  querySelector("#btnBrownNoiseWave").onClick.listen((Event e) => _brownNoise(e));
  
  querySelector("#btnPlay").onClick.listen((Event e) => _play(e));
  //querySelector("#btnDumpSamples").onClick.listen((Event e) => _dump(e));
  querySelector("#btnDumpSettings").onClick.listen((Event e) => _dumpAsSettings(e));
  
  querySelector("#btnDesktopOpen").onClick.listen((Event e) => _getDesktopFile());

  querySelector("#enableFlangerId").onClick.listen((Event e) => _enableDisableFlanger());
  querySelector("#enableFrequencyId").onClick.listen((Event e) => _enableDisableFrequency());
  querySelector("#enableTremoloId").onClick.listen((Event e) => _enableDisableTremolo());
  querySelector("#enableDistortionId").onClick.listen((Event e) => _enableDistortion());
  querySelector("#enableVibratoId").onClick.listen((Event e) => _enableVibrato());
  querySelector("#enableLowPassId").onClick.listen((Event e) => _enableLowPass());
  querySelector("#enableHighPassId").onClick.listen((Event e) => _enableHighPass());

  querySelector("#btnResetDutyCycle").onClick.listen((Event e) => _resets("DutyCycle"));
  querySelector("#btnResetDutySweep").onClick.listen((Event e) => _resets("DutySweep"));
  querySelector("#btnResetSlide").onClick.listen((Event e) => _resets("Slide"));
  
  querySelector("#btnUpdateEffectName").onClick.listen((Event e) => _updateEffectName());
  querySelector("#btnUpdateOutputName").onClick.listen((Event e) => _updateOutputName());
  
  querySelector("#arpeStepTypeUpId").onClick.listen((Event e) => _clickArpeStepType(Ranger.WAArpeggio.STEP_UP));
  querySelector("#arpeStepTypeDownId").onClick.listen((Event e) => _clickArpeStepType(Ranger.WAArpeggio.STEP_DOWN));
  querySelector("#arpeStepTypeBounceId").onClick.listen((Event e) => _clickArpeStepType(Ranger.WAArpeggio.STEP_BOUNCE));
  
  
  // ---------------------------------------------------------------
  // Envelope
  // ---------------------------------------------------------------
  _AttackSlider = new Slider.basic(
      querySelector("#attackTimeId"), querySelector("#attackTimeView"), 
      _attackChange, _attackSlide);
  _DecaySlider = new Slider.basic(
      querySelector("#decayTimeId"), querySelector("#decayTimeView"), 
      _decayChange, _decaySlide);
  _SustainSlider = new Slider.basic(
      querySelector("#sustainTimeId"), querySelector("#sustainTimeView"), 
      _sustainChange, _sustainSlide);
  _ReleaseSlider = new Slider.basic(
      querySelector("#releaseTimeId"), querySelector("#releaseTimeView"), 
      _releaseChange, _releaseSlide);

  // ---------------------------------------------------------------
  // Freq Slider
  // ---------------------------------------------------------------
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
  _FreqGainSlider = new Slider.basic(
      querySelector("#freqGainSlideId"), querySelector("#freqGainSlideView"), 
      _freqGainChange, _freqGainSlide);

  // ---------------------------------------------------------------
  // Vibrato
  // ---------------------------------------------------------------
  _VibratoDepthSlider = new Slider.basic(
      querySelector("#depthId"), querySelector("#depthView"), 
      _depthChange, _depthSlide);
  _VibratoSpeedSlider = new Slider.basic(
      querySelector("#speedId"), querySelector("#speedView"), 
      _speedChange, _speedSlide);

  // ---------------------------------------------------------------
  // Tremolo
  // ---------------------------------------------------------------
  _TremoloDepthSlider = new Slider.basic(
      querySelector("#tremoloDepthId"), querySelector("#tremoloDepthView"), 
      _tremoloDepthChange, _tremoloDepthSlide);
  _TremoloSpeedSlider = new Slider.basic(
      querySelector("#tremoloSpeedId"), querySelector("#tremoloSpeedView"), 
      _tremoloSpeedChange, _tremoloSpeedSlide);

  // ---------------------------------------------------------------
  // Arpeggio
  // ---------------------------------------------------------------
  _ArpeFreqStepSlider = new Slider.basic(
      querySelector("#arpeFreqStepId"), querySelector("#arpeFreqStepView"), 
      _arpeFreqStepChange, _arpeFreqStepSlide);
  _ArpeTimeStepSlider = new Slider.basic(
      querySelector("#arpeTimeStepId"), querySelector("#arpeTimeStepView"), 
      _arpeTimeStepChange, _arpeTimeStepSlide);
  _ArpeExpoDecaySlider = new Slider.basic(
      querySelector("#arpeExpoDecayId"), querySelector("#arpeExpoDecayView"), 
      _arpeExpoDecayChange, _arpeExpoDecaySlide);
  _ArpeNotesSlider = new Slider.basic(
      querySelector("#arpeNotesId"), querySelector("#arpeNotesView"), 
      _arpeNotesChange, _arpeNotesSlide);

  // ---------------------------------------------------------------
  // Square/Sawtooth
  // ---------------------------------------------------------------
  _DutyCycleSlider = new Slider.basic(
      querySelector("#dutyCycleId"), querySelector("#dutyCycleView"), 
      _dutyCycleChange, _dutyCycleSlide);
  _SweepSlider = new Slider.basic(
      querySelector("#sweepId"), querySelector("#sweepView"), 
      _sweepChange, _sweepSlide);

  // ---------------------------------------------------------------
  // Retrigger
  // ---------------------------------------------------------------
  _RetriggerCountSlider = new Slider.basic(
      querySelector("#retriggerCountId"), querySelector("#retriggerCountView"), 
      _retriggerCountChange, _retriggerCountSlide);
  _RetriggerRateSlider = new Slider.basic(
      querySelector("#retriggerRateId"), querySelector("#retriggerRateView"), 
      _retriggerRateChange, _retriggerRateSlide);

  // ---------------------------------------------------------------
  // low pass
  // ---------------------------------------------------------------
  _LowPassCutoffSlider = new Slider.basic(
      querySelector("#lpCutoffFreqId"), querySelector("#lpCutoffFreqView"), 
      _lpCutoffFreqChange, _lpCutoffFreqSlide);
  _LowPassSweepSlider = new Slider.basic(
      querySelector("#lpCutoffSweepId"), querySelector("#lpCutoffSweepView"), 
      _lpCutoffSweepChange, _lpCutoffSweepSlide);
  _LowPassResonanceSlider = new Slider.basic(
      querySelector("#lpResonanceId"), querySelector("#lpResonanceView"), 
      _lpResonanceChange, _lpResonanceSlide);

  // ---------------------------------------------------------------
  // high pass
  // ---------------------------------------------------------------
  _HighPassCutoffSlider = new Slider.basic(
      querySelector("#hpCutoffFreqId"), querySelector("#hpCutoffFreqView"), 
      _hpCutoffFreqChange, _hpCutoffFreqSlide);
  _HighPassSweepSlider = new Slider.basic(
      querySelector("#hpCutoffSweepId"), querySelector("#hpCutoffSweepView"), 
      _hpCutoffSweepChange, _hpCutoffSweepSlide);
  _HighPassResonanceSlider = new Slider.basic(
      querySelector("#hpResonanceId"), querySelector("#hpResonanceView"), 
      _hpResonanceChange, _hpResonanceSlide);
  
  // ---------------------------------------------------------------
  // Noise
  // ---------------------------------------------------------------
  _NoisePlaybackRateSlider = new Slider.basic(
      querySelector("#noisePlaybackRateId"), querySelector("#noisePlaybackRateView"), 
      _noisePlaybackRateChange, _noisePlaybackRateSlide);
  _NoiseBufferSizeSlider = new Slider.basic(
      querySelector("#noiseBufferSizeId"), querySelector("#noiseBufferSizeView"), 
      _noiseBufferSizeChange, _noiseBufferSizeSlide);
  _NoiseVolumeSlider = new Slider.basic(
      querySelector("#noiseVolumeId"), querySelector("#noiseVolumeView"), 
      _noiseVolumeChange, _noiseVolumeSlide);
  _NoiseOverdriveSlider = new Slider.basic(
      querySelector("#noiseOverdriveId"), querySelector("#noiseOverdriveView"), 
      _noiseOverdriveChange, _noiseOverdriveSlide);

  // ---------------------------------------------------------------
  // Flanger
  // ---------------------------------------------------------------
  _FlangerFreqSlider = new Slider.basic(
      querySelector("#flangerFreqId"), querySelector("#flangerFreqView"), 
      _flangerFreqChange, _flangerFreqSlide);
  _FlangerDelaySlider = new Slider.basic(
      querySelector("#flangerDelayScalerId"), querySelector("#flangerDelayScalerView"), 
      _flangerDelayScalerChange, _flangerDelayScalerSlide);
  _FlangerFeedbackSlider = new Slider.basic(
      querySelector("#flangerFeedbackId"), querySelector("#flangerFeedbackView"), 
      _flangerFeedbackChange, _flangerFeedbackSlide);
  _FlangerFeedbackSweepSlider = new Slider.basic(
      querySelector("#flangerFeedbackSweepId"), querySelector("#flangerFeedbackSweepView"), 
      _flangerFeedbackSweepChange, _flangerFeedbackSweepSlide);
  _FlangerBaseDelaySlider = new Slider.basic(
      querySelector("#flangerBaseDelayId"), querySelector("#flangerBaseDelayView"), 
      _flangerBaseDelayChange, _flangerBaseDelaySlide);
  
  // ---------------------------------------------------------------
  // Distortion
  // ---------------------------------------------------------------
  _DistortionScaleSlider = new Slider.basic(
      querySelector("#distScaleId"), querySelector("#distScaleView"), 
      _distScaleChange, _distScaleViewSlide);
  _DistortionPartsSlider = new Slider.basic(
      querySelector("#distSumPartsId"), querySelector("#distSumPartsView"), 
      _distSumPartsChange, _distSumPartsSlide);
  _DistortionMag1Slider = new Slider.basic(
      querySelector("#distMag1Id"), querySelector("#distMag1View"), 
      _distMag1Change, _distMag1Slide);
  _DistortionMag2Slider = new Slider.basic(
      querySelector("#distMag2Id"), querySelector("#distMag2View"), 
      _distMag2Change, _distMag2Slide);
  _DistortionMag3Slider = new Slider.basic(
      querySelector("#distMag3Id"), querySelector("#distMag3View"), 
      _distMag3Change, _distMag3Slide);
  _DistortionEquationSlider = new Slider.basic(
      querySelector("#distEquationId"), querySelector("#distEquationView"), 
      _distEquationChange, _distEquationSlide);
  _DistortionClampSlider = new Slider.basic(
      querySelector("#distClampId"), querySelector("#distClampView"), 
      _distClampChange, _distClampSlide);

  // ---------------------------------------------------------------
  // Gain
  // ---------------------------------------------------------------
  _GainSlider = new Slider.basic(
      querySelector("#soundVolumeId"), querySelector("#gainView"), 
      _soundVolumeChange, _soundVolumeSlide);
  
  _btnHiddenFileElement = querySelector("#fileElem");
  
  _audioMixer.selectChannel(0);
  _updateView(true);

  _audioMixer.trigger();
}

void _resets(String what) {
  if (what == "DutyCycle")
    _audioMixer.effect.resetDutyCycle();
  else if (what == "DutySweep")
    _audioMixer.effect.resetDutySweep();
  else if (what == "Slide")
    _audioMixer.effect.resetFreqSlide();
    
  _updateView(true);
  _audioMixer.trigger();
}

void _channelsCallback(int index, String action, bool enabled, bool active, double gain, double delay) {
  _audioMixer.channelsCallback(index, action, enabled, active, gain, delay);

  _updateView(true);
}

void _updateFocusField(String name) {
  InputElement _name = querySelector("#effectNameId");
  _name.value = name;
}

void _updateEffectName() {
  InputElement name = querySelector("#effectNameId");
  _audioMixer.setEffectName = name.value;
}

void _updateOutputName() {
  InputElement name = querySelector("#outputNameId");
  _audioMixer.name = name.value;
}

void _resetMixerPanel() {
  for (int i = 0; i < Ranger.AudioMixer.MAX_CHANNELS; i++) {
    ChannelWidget cw = _channelWidgets[i];
    cw.gain = 1.0;
    cw.delay = 0.0;
    cw.enabled = false;
  }
}

void _updateView([bool loading = false]) {
  for (int i = 0; i < _audioMixer.enabledChannels; i++) {
    ChannelWidget cw = _channelWidgets[i];
    cw.gain = _audioMixer.getChannelGain(i);
    cw.delay = _audioMixer.getChannelDelay(i);
    cw.enabled = _audioMixer.getEnableChannel(i);
  }
  
  _updateFocusField(_audioMixer.effect.name);

  _AttackSlider.text = _audioMixer.effect.envelope.attack[Ranger.WAEnvelope.TIME].toStringAsFixed(3);
  _SustainSlider.text = _audioMixer.effect.envelope.sustain[Ranger.WAEnvelope.TIME].toStringAsFixed(3);
  _ReleaseSlider.text = _audioMixer.effect.envelope.release[Ranger.WAEnvelope.TIME].toStringAsFixed(3);
  _DecaySlider.text = _audioMixer.effect.envelope.decay[Ranger.WAEnvelope.TIME].toStringAsFixed(3);
  
  _StartFreqSlider.text = _audioMixer.effect.frequency.toStringAsFixed(3);
  _SlideSlider.text = _audioMixer.effect.slideFrequency.toStringAsFixed(3);
  _MinCutoffSlider.text = _audioMixer.effect.slideCutoff.toStringAsFixed(3);
  _DeltaSlideSlider.text = _audioMixer.effect.slideTime.toStringAsFixed(3);
  _FreqGainSlider.text = _audioMixer.effect.frequencyGain.toStringAsFixed(2);

  _VibratoDepthSlider.text = _audioMixer.effect.vibratoStrength.toStringAsFixed(3);
  _VibratoSpeedSlider.text = _audioMixer.effect.vibratoFrequency.toStringAsFixed(3);

  _TremoloDepthSlider.text = _audioMixer.effect.tremoloStrength.toStringAsFixed(3);
  _TremoloSpeedSlider.text = _audioMixer.effect.tremoloFrequency.toStringAsFixed(3);

  _ArpeFreqStepSlider.text = _audioMixer.effect.arpefrequencyStep.toStringAsFixed(3);
  _ArpeTimeStepSlider.text = _audioMixer.effect.arpeTimeStep.toStringAsFixed(3);
  _ArpeExpoDecaySlider.text = _audioMixer.effect.arpeExpoDecay.toStringAsFixed(3);
  _ArpeNotesSlider.text = _audioMixer.effect.arpeNotes.toString();

  _DutyCycleSlider.text = (_audioMixer.effect.dutyCycle * 100.0).toStringAsFixed(2);
  _SweepSlider.text = _audioMixer.effect.dutySweep.toStringAsFixed(3);

  _RetriggerCountSlider.text = _audioMixer.effect.retriggerCount.toStringAsFixed(0);
  _RetriggerRateSlider.text = _audioMixer.effect.retriggerRate.toStringAsFixed(3);

  _FlangerFreqSlider.text = _audioMixer.effect.FlangerFrequency.toStringAsFixed(2);
  _FlangerDelaySlider.text = _audioMixer.effect.FlangerDelayScaler.toStringAsFixed(2);
  _FlangerFeedbackSlider.text = _audioMixer.effect.FlangerFeedback.toStringAsFixed(2);
  _FlangerFeedbackSweepSlider.text = _audioMixer.effect.FlangerFeedbackSweep.toStringAsFixed(2);
  _FlangerBaseDelaySlider.text = _audioMixer.effect.FlangerBaseDelay.toStringAsFixed(2);

  _LowPassCutoffSlider.text = _audioMixer.effect.lowPassFrequency.toStringAsFixed(3);
  _LowPassSweepSlider.text = _audioMixer.effect.lowPassSweep.toStringAsFixed(3);
  _LowPassResonanceSlider.text = _audioMixer.effect.lowPassResonance.toStringAsFixed(2);

  _HighPassCutoffSlider.text = _audioMixer.effect.highPassFrequency.toStringAsFixed(3);
  _HighPassSweepSlider.text = _audioMixer.effect.highPassSweep.toStringAsFixed(3);
  _HighPassResonanceSlider.text = _audioMixer.effect.highPassResonance.toStringAsFixed(2);
  
  _NoisePlaybackRateSlider.text = _audioMixer.effect.NoisePlaybackRate.toStringAsFixed(3);
  _NoiseBufferSizeSlider.text = _audioMixer.effect.NoiseBufferSize.toStringAsFixed(0);
  _NoiseVolumeSlider.text = _audioMixer.effect.NoiseVolume.toStringAsFixed(3);
  _NoiseOverdriveSlider.text = _audioMixer.effect.NoiseOverdrive.toStringAsFixed(3);
  
  InputElement e = querySelector("#enableDistortionId");
  e.checked = _audioMixer.effect.DistortionEnabled;

  if (!_audioMixer.effect.DistortionEnabled) {
    querySelector("#distortionTitle").classes.add("titleDisabled");
  }
  else {
    querySelector("#distortionTitle").classes.remove("titleDisabled");
  }
  
  _DistortionScaleSlider.text = _audioMixer.effect.DistortionScale.toStringAsFixed(3);
  _DistortionPartsSlider.text = _audioMixer.effect.DistortionParts.toStringAsFixed(0);
  _DistortionMag1Slider.text = _audioMixer.effect.DistortionMag1.toStringAsFixed(3);
  _DistortionMag2Slider.text = _audioMixer.effect.DistortionMag2.toStringAsFixed(3);
  _DistortionMag3Slider.text = _audioMixer.effect.DistortionMag3.toStringAsFixed(3);
  _DistortionEquationSlider.text = _audioMixer.effect.DistortionEquation.toStringAsFixed(0);
  _DistortionClampSlider.text = _audioMixer.effect.DistortionClamp.toStringAsFixed(3);

  _GainSlider.text = _audioMixer.gain.toStringAsFixed(2);

  InputElement l = querySelector("#outputNameId");
  l.value = _audioMixer.name;
  
  e = querySelector("#enableFrequencyId");
  e.checked = _audioMixer.effect.frequencyEnabled;

  if (!_audioMixer.effect.frequencyEnabled) {
    querySelector("#frequencyTitle").classes.add("titleDisabled");
  }
  else {
    querySelector("#frequencyTitle").classes.remove("titleDisabled");
  }

  e = querySelector("#enableTremoloId");
  e.checked = _audioMixer.effect.tremoloEnabled;

  if (!_audioMixer.effect.tremoloEnabled) {
    querySelector("#tremoloTitle").classes.add("titleDisabled");
  }
  else {
    querySelector("#tremoloTitle").classes.remove("titleDisabled");
  }

  e = querySelector("#enableVibratoId");
  e.checked = _audioMixer.effect.vibratoEnabled;
  
  if (!_audioMixer.effect.vibratoEnabled) {
    querySelector("#vibratoTitle").classes.add("titleDisabled");
  }
  else {
    querySelector("#vibratoTitle").classes.remove("titleDisabled");
  }

  e = querySelector("#enableFlangerId");
  e.checked = _audioMixer.effect.flangerEnabled;

  if (!_audioMixer.effect.flangerEnabled) {
    querySelector("#flangerTitle").classes.add("titleDisabled");
  }
  else {
    querySelector("#flangerTitle").classes.remove("titleDisabled");
  }

  e = querySelector("#enableLowPassId");
  e.checked = _audioMixer.effect.lowPassEnabled;

  if (!_audioMixer.effect.lowPassEnabled) {
    querySelector("#lowPassTitle").classes.add("titleDisabled");
  }
  else {
    querySelector("#lowPassTitle").classes.remove("titleDisabled");
  }
  
  e = querySelector("#enableHighPassId");
  e.checked = _audioMixer.effect.highPassEnabled;

  if (!_audioMixer.effect.highPassEnabled) {
    querySelector("#highPassTitle").classes.add("titleDisabled");
  }
  else {
    querySelector("#highPassTitle").classes.remove("titleDisabled");
  }
  

  RadioButtonInputElement r;
  if (_audioMixer.effect.arpeStepType == Ranger.WAArpeggio.STEP_UP) {
    RadioButtonInputElement r = querySelector("#arpeStepTypeUpId");
    r.checked = true;
  }
  else if (_audioMixer.effect.arpeStepType == Ranger.WAArpeggio.STEP_DOWN) {
    RadioButtonInputElement r = querySelector("#arpeStepTypeDownId");
    r.checked = true;
  }
  else if (_audioMixer.effect.arpeStepType == Ranger.WAArpeggio.STEP_BOUNCE) {
    RadioButtonInputElement r = querySelector("#arpeStepTypeBounceId");
    r.checked = true;
  }

  _resetGenTextStyles();
  _resetOscTextStyles();
  
  _selectOscillator(_audioMixer.effect.OscillatorType);
  _selectGenerator(_audioMixer.effect.category);
  
  if (loading) {
    _AttackSlider.doubleValue = _audioMixer.effect.envelope.attack[Ranger.WAEnvelope.TIME];
    _SustainSlider.doubleValue = _audioMixer.effect.envelope.sustain[Ranger.WAEnvelope.TIME];
    _DecaySlider.doubleValue = _audioMixer.effect.envelope.decay[Ranger.WAEnvelope.TIME];
    _ReleaseSlider.doubleValue = _audioMixer.effect.envelope.release[Ranger.WAEnvelope.TIME];
    
    _StartFreqSlider.doubleValue = _audioMixer.effect.frequency;
    _SlideSlider.doubleValue = _audioMixer.effect.slideFrequency;
    _MinCutoffSlider.doubleValue = _audioMixer.effect.slideCutoff;
    _DeltaSlideSlider.doubleValue = _audioMixer.effect.slideTime;
    _FreqGainSlider.doubleValue = _audioMixer.effect.frequencyGain;

    _VibratoDepthSlider.doubleValue = _audioMixer.effect.vibratoStrength;
    _VibratoSpeedSlider.doubleValue = _audioMixer.effect.vibratoFrequency;

    _TremoloDepthSlider.doubleValue = _audioMixer.effect.tremoloStrength;
    _TremoloSpeedSlider.doubleValue = _audioMixer.effect.tremoloFrequency;

    _ArpeFreqStepSlider.doubleValue = _audioMixer.effect.arpefrequencyStep;
    _ArpeTimeStepSlider.doubleValue = _audioMixer.effect.arpeTimeStep;
    _ArpeExpoDecaySlider.doubleValue = _audioMixer.effect.arpeExpoDecay;
    _ArpeNotesSlider.intValue = _audioMixer.effect.arpeNotes;

    _DutyCycleSlider.doubleValue = _audioMixer.effect.dutyCycle;
    _SweepSlider.doubleValue = _audioMixer.effect.dutySweep;

    _RetriggerCountSlider.intValue = _audioMixer.effect.retriggerCount;
    _RetriggerRateSlider.doubleValue = _audioMixer.effect.retriggerRate;

    _FlangerFreqSlider.doubleValue = _audioMixer.effect.FlangerFrequency;
    _FlangerDelaySlider.doubleValue = _audioMixer.effect.FlangerDelayScaler;
    _FlangerFeedbackSlider.doubleValue = _audioMixer.effect.FlangerFeedback;
    _FlangerFeedbackSweepSlider.doubleValue = _audioMixer.effect.FlangerFeedbackSweep;
    _FlangerBaseDelaySlider.doubleValue = _audioMixer.effect.FlangerBaseDelay;

    _LowPassCutoffSlider.doubleValue = _audioMixer.effect.lowPassFrequency;
    _LowPassSweepSlider.doubleValue = _audioMixer.effect.lowPassSweep;
    _LowPassResonanceSlider.doubleValue = _audioMixer.effect.lowPassResonance;
    
    _HighPassCutoffSlider.doubleValue = _audioMixer.effect.highPassFrequency;
    _HighPassSweepSlider.doubleValue = _audioMixer.effect.highPassSweep;
    _HighPassResonanceSlider.doubleValue = _audioMixer.effect.highPassResonance;
    
    _NoisePlaybackRateSlider.doubleValue = _audioMixer.effect.NoisePlaybackRate;
    _NoiseBufferSizeSlider.intValue = _audioMixer.effect.NoiseBufferSize;
    _NoiseVolumeSlider.doubleValue = _audioMixer.effect.NoiseVolume;
    _NoiseOverdriveSlider.doubleValue = _audioMixer.effect.NoiseOverdrive;

    _DistortionScaleSlider.doubleValue = _audioMixer.effect.DistortionScale;
    _DistortionPartsSlider.intValue = _audioMixer.effect.DistortionParts;
    _DistortionMag1Slider.doubleValue = _audioMixer.effect.DistortionMag1;
    _DistortionMag2Slider.doubleValue = _audioMixer.effect.DistortionMag2;
    _DistortionMag3Slider.doubleValue = _audioMixer.effect.DistortionMag3;
    _DistortionEquationSlider.intValue = _audioMixer.effect.DistortionEquation;
    _DistortionClampSlider.doubleValue = _audioMixer.effect.DistortionClamp;

    _GainSlider.doubleValue = _audioMixer.gain;
  }
}

// -----------------------------------------------------------------
// Envelope
// -----------------------------------------------------------------
void _attackChange() {
  _audioMixer.trigger();
}

void _attackSlide() {
  _audioMixer.effect.envelope.setAttack(1.0, _AttackSlider.doubleValue);
  _updateView();
}

void _decayChange() {
  _audioMixer.trigger();
}

void _decaySlide() {
  _audioMixer.effect.envelope.setDecay(1.0, _DecaySlider.doubleValue);
  _updateView();
}

void _sustainChange() {
  _audioMixer.trigger();
}

void _sustainSlide() {
  _audioMixer.effect.envelope.setSustain(1.0, _SustainSlider.doubleValue);
  _updateView();
}

void _releaseChange() {
  _audioMixer.trigger();
}

void _releaseSlide() {
  _audioMixer.effect.envelope.setRelease(0.0, _ReleaseSlider.doubleValue);
  _updateView();
}

void _sustainPunchChange() {
}

void _sustainPunchSlide() {
}

// -----------------------------------------------------------------
// Frequency
// -----------------------------------------------------------------
void _enableDisableFrequency() {
  bool enabled = _audioMixer.effect.toggleFrequency();
  if (enabled)
    querySelector("#frequencyTitle").classes.add("titleDisabled");
  else
    querySelector("#frequencyTitle").classes.remove("titleDisabled");
  _audioMixer.trigger();
}

void _startFreqChange() {
  _audioMixer.trigger();
}

void _startFreqSlide() {
  _audioMixer.effect.frequency = _StartFreqSlider.doubleValue;
  _updateView();
}

void _minCutoffChange() {
  _audioMixer.trigger();
}

void _minCutoffSlide() {
  _audioMixer.effect.slideCutoff = _MinCutoffSlider.doubleValue;
  _updateView();
}

void _slideChange() {
  _audioMixer.trigger();
}

void _slideSlide() {
  _audioMixer.effect.slideFrequency = _SlideSlider.doubleValue;
  _updateView();
}

void _deltaSlideChange() {
  _audioMixer.trigger();
}

void _deltaSlideSlide() {
  _audioMixer.effect.slideTime = _DeltaSlideSlider.doubleValue;
  _updateView();
}

void _freqGainChange() {
  _audioMixer.trigger();
}

void _freqGainSlide() {
  _audioMixer.effect.frequencyGain = _FreqGainSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Vibrato
// -----------------------------------------------------------------
void _enableVibrato() {
  bool enabled = _audioMixer.effect.toggleVibrato();
  querySelector("#vibratoTitle").classes.toggle("titleDisabled");
  _audioMixer.trigger();
}

void _depthChange() {
  _audioMixer.trigger();
}

void _depthSlide() {
  _audioMixer.effect.vibratoStrength = _VibratoDepthSlider.doubleValue;
  _updateView();
}

void _speedChange() {
  _audioMixer.trigger();
}

void _speedSlide() {
  _audioMixer.effect.vibratoFrequency = _VibratoSpeedSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Tremolo
// -----------------------------------------------------------------
void _tremoloDepthChange() {
  _audioMixer.trigger();
}

void _tremoloDepthSlide() {
  _audioMixer.effect.tremoloStrength = _TremoloDepthSlider.doubleValue;
  _updateView();
}

void _tremoloSpeedChange() {
  _audioMixer.trigger();
}

void _tremoloSpeedSlide() {
  _audioMixer.effect.tremoloFrequency = _TremoloSpeedSlider.doubleValue;
  _updateView();
}


// -----------------------------------------------------------------
// Arpeggiation
// -----------------------------------------------------------------
void _arpeFreqStepChange() {
  _audioMixer.trigger();
}

void _arpeFreqStepSlide() {
  _audioMixer.effect.arpefrequencyStep = _ArpeFreqStepSlider.doubleValue;
  _updateView();
}

void _arpeTimeStepChange() {
  _audioMixer.trigger();
}

void _arpeTimeStepSlide() {
  _audioMixer.effect.arpeTimeStep = _ArpeTimeStepSlider.doubleValue;
  _updateView();
}

void _arpeExpoDecayChange() {
  _audioMixer.trigger();
}

void _arpeExpoDecaySlide() {
  _audioMixer.effect.arpeExpoDecay = _ArpeExpoDecaySlider.doubleValue;
  _updateView();
}

void _arpeNotesChange() {
  _audioMixer.trigger();
}

void _arpeNotesSlide() {
  _audioMixer.effect.arpeNotes = _ArpeNotesSlider.intValue;
  _updateView();
}

void _clickArpeStepType(int type) {
  _audioMixer.effect.arpeStepType = type;
  _audioMixer.trigger();
}

// -----------------------------------------------------------------
// Duty Cycle
// -----------------------------------------------------------------
void _enableDutyCycle() {
  //bool enabled = _audio.effect.toggleFlanger();
  querySelector("#dutyTitle").classes.toggle("titleDisabled");
  _audioMixer.trigger();
}

void _dutyCycleChange() {
  _audioMixer.trigger();
}

void _dutyCycleSlide() {
  _audioMixer.effect.dutyCycle = _DutyCycleSlider.doubleValue;
  _updateView();
}

void _sweepChange() {
  _audioMixer.trigger();
}

void _sweepSlide() {
  _audioMixer.effect.dutySweep = _SweepSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Retrigger
// -----------------------------------------------------------------
void _retriggerCountChange() {
  _audioMixer.trigger();
}

void _retriggerCountSlide() {
  _audioMixer.effect.retriggerCount = _RetriggerCountSlider.intValue;
  _updateView();
}

void _retriggerRateChange() {
  _audioMixer.trigger();
}

void _retriggerRateSlide() {
  _audioMixer.effect.retriggerRate = _RetriggerRateSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Flanger
// -----------------------------------------------------------------
void _enableDisableFlanger() {
  bool enabled = _audioMixer.effect.toggleFlanger();
  querySelector("#flangerTitle").classes.toggle("titleDisabled");
  _audioMixer.trigger();
}

void _flangerFreqChange() {
  _audioMixer.trigger();
}

void _flangerFreqSlide() {
  _audioMixer.effect.FlangerFrequency = _FlangerFreqSlider.doubleValue;
  _updateView();
}

void _flangerDelayScalerChange() {
  _audioMixer.trigger();
}

void _flangerDelayScalerSlide() {
  _audioMixer.effect.FlangerDelayScaler = _FlangerDelaySlider.doubleValue;
  _updateView();
}

void _flangerFeedbackChange() {
  _audioMixer.trigger();
}

void _flangerFeedbackSlide() {
  _audioMixer.effect.FlangerFeedback = _FlangerFeedbackSlider.doubleValue;
  _updateView();
}

void _flangerFeedbackSweepChange() {
  _audioMixer.trigger();
}

void _flangerFeedbackSweepSlide() {
  _audioMixer.effect.FlangerFeedbackSweep = _FlangerFeedbackSweepSlider.doubleValue;
  _updateView();
}

void _flangerBaseDelayChange() {
  _audioMixer.trigger();
}

void _flangerBaseDelaySlide() {
  _audioMixer.effect.FlangerBaseDelay = _FlangerBaseDelaySlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Distortion
// -----------------------------------------------------------------
void _enableDistortion() {
  bool enabled = _audioMixer.effect.toggleDistortion();
  querySelector("#distortionTitle").classes.toggle("titleDisabled");
  _audioMixer.trigger();
}

void _distScaleChange() {
  _audioMixer.trigger();
}

void _distScaleViewSlide() {
  _audioMixer.effect.DistortionScale = _DistortionScaleSlider.doubleValue;
  _updateView();
}

void _distSumPartsChange() {
  _audioMixer.trigger();
}

void _distSumPartsSlide() {
  _audioMixer.effect.DistortionParts = _DistortionPartsSlider.intValue;
  _updateView();
}

void _distMag1Change() {
  _audioMixer.trigger();
}

void _distMag1Slide() {
  _audioMixer.effect.DistortionMag1 = _DistortionMag1Slider.doubleValue;
  _updateView();
}

void _distMag2Change() {
  _audioMixer.trigger();
}

void _distMag2Slide() {
  _audioMixer.effect.DistortionMag2 = _DistortionMag2Slider.doubleValue;
  _updateView();
}

void _distMag3Change() {
  _audioMixer.trigger();
}

void _distMag3Slide() {
  _audioMixer.effect.DistortionMag3 = _DistortionMag3Slider.doubleValue;
  _updateView();
}

void _distEquationChange() {
  _audioMixer.trigger();
}

void _distEquationSlide() {
  _audioMixer.effect.DistortionEquation = _DistortionEquationSlider.intValue;
  _updateView();
}

void _distClampChange() {
  _audioMixer.trigger();
}

void _distClampSlide() {
  _audioMixer.effect.DistortionClamp = _DistortionClampSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Tremolo
// -----------------------------------------------------------------
void _enableDisableTremolo() {
  bool enabled = _audioMixer.effect.toggleTremolo();
  querySelector("#tremoloTitle").classes.toggle("titleDisabled");
  _audioMixer.trigger();
}

// -----------------------------------------------------------------
// Low pass
// -----------------------------------------------------------------
void _enableLowPass() {
  bool enabled = _audioMixer.effect.toggleLowPass();
  querySelector("#lowPassTitle").classes.toggle("titleDisabled");
  _audioMixer.trigger();
}

void _lpCutoffFreqChange() {
  _audioMixer.trigger();
}

void _lpCutoffFreqSlide() {
  _audioMixer.effect.lowPassFrequency = _LowPassCutoffSlider.doubleValue;
  _updateView();
}

void _lpCutoffSweepChange() {
  _audioMixer.trigger();
}

void _lpCutoffSweepSlide() {
  _audioMixer.effect.lowPassSweep = _LowPassSweepSlider.doubleValue;
  _updateView();
}

void _lpResonanceChange() {
  _audioMixer.trigger();
}

void _lpResonanceSlide() {
  _audioMixer.effect.lowPassResonance = _LowPassResonanceSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// High pass
// -----------------------------------------------------------------
void _enableHighPass() {
  bool enabled = _audioMixer.effect.toggleHighPass();
  querySelector("#highPassTitle").classes.toggle("titleDisabled");
  _audioMixer.trigger();
}

void _hpCutoffFreqChange() {
  _audioMixer.trigger();
}

void _hpCutoffFreqSlide() {
  _audioMixer.effect.highPassFrequency = _HighPassCutoffSlider.doubleValue;
  _updateView();
}

void _hpCutoffSweepChange() {
  _audioMixer.trigger();
}

void _hpCutoffSweepSlide() {
  _audioMixer.effect.highPassSweep = _HighPassSweepSlider.doubleValue;
  _updateView();
}

void _hpResonanceChange() {
  _audioMixer.trigger();
}

void _hpResonanceSlide() {
  _audioMixer.effect.highPassResonance = _HighPassResonanceSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Noise
// -----------------------------------------------------------------
void _noisePlaybackRateChange() {
  _audioMixer.trigger();
}

void _noisePlaybackRateSlide() {
  _audioMixer.effect.NoisePlaybackRate = _NoisePlaybackRateSlider.doubleValue;
  _updateView();
}

void _noiseBufferSizeChange() {
  _audioMixer.trigger();
}

void _noiseBufferSizeSlide() {
  _audioMixer.effect.NoiseBufferSize = _NoiseBufferSizeSlider.intValue;
  _updateView();
}

void _noiseVolumeChange() {
  _audioMixer.trigger();
}

void _noiseVolumeSlide() {
  _audioMixer.effect.NoiseVolume = _NoiseVolumeSlider.doubleValue;
  _updateView();
}

void _noiseOverdriveChange() {
  _audioMixer.trigger();
}

void _noiseOverdriveSlide() {
  _audioMixer.effect.NoiseOverdrive = _NoiseOverdriveSlider.doubleValue;
  _updateView();
}

// -----------------------------------------------------------------
// Gain
// -----------------------------------------------------------------
void _soundVolumeChange() {
  _audioMixer.trigger();
}

void _soundVolumeSlide() {
  _audioMixer.gain = _GainSlider.doubleValue;
  _updateView();
}

void _sine(Event e) {
  _resetOscTextStyles();
  _selectSine();
  _audioMixer.effect.OscillatorType = Ranger.WASfxr.SINE;
  _audioMixer.effect.enableFrequency();
  _updateView(true);
  _audioMixer.trigger();
}

void _square(Event e) {
  _resetOscTextStyles();
  _selectSquare();
  _audioMixer.effect.OscillatorType = Ranger.WASfxr.SQUARE;
  _audioMixer.effect.enableFrequency();
  _updateView(true);
  _audioMixer.trigger();
}

void _sawtooth(Event e) {
  _resetOscTextStyles();
  _selectSawtooth();
  _audioMixer.effect.OscillatorType = Ranger.WASfxr.SAWTOOTH;
  _audioMixer.effect.enableFrequency();
  _updateView(true);
  _audioMixer.trigger();
}

void _triangle(Event e) {
  _resetOscTextStyles();
  _selectTriangle();
  _audioMixer.effect.OscillatorType = Ranger.WASfxr.TRIANGLE;
  _audioMixer.effect.enableFrequency();
  _updateView(true);
  _audioMixer.trigger();
}

void _whiteNoise(Event e) {
  _resetOscTextStyles();
  _selectNoise();
  _audioMixer.effect.OscillatorType = Ranger.WASfxr.NOISE;
  _audioMixer.effect.connectDistortion(false);
  _audioMixer.effect.disableFrequency();
  _updateView(true);
  _audioMixer.trigger();
}

void _pinkNoise(Event e) {
  _resetOscTextStyles();
  _selectPink();
  _audioMixer.effect.OscillatorType = Ranger.WASfxr.NOISE_PINK;
  _audioMixer.effect.connectDistortion(false);
  _audioMixer.effect.disableFrequency();
  _updateView(true);
  _audioMixer.trigger();
}

void _brownNoise(Event e) {
  _resetOscTextStyles();
  _selectBrown();
  _audioMixer.effect.OscillatorType = Ranger.WASfxr.NOISE_BROWNIAN;
  _audioMixer.effect.connectDistortion(false);
  _audioMixer.effect.disableFrequency();
  _updateView(true);
  _audioMixer.trigger();
}

void _resetOscTextStyles() {
  querySelector("#sineText").style.color ="#ffffff";
  querySelector("#squareText").style.color ="#ffffff";
  querySelector("#sawtoothText").style.color ="#ffffff";
  querySelector("#triangleText").style.color ="#ffffff";
  querySelector("#whiteText").style.color ="#ffffff";
  querySelector("#pinkText").style.color ="#ffffff";
  querySelector("#brownText").style.color ="#ffffff";
}

void _selectSquare() {
  querySelector("#squareText").style.color ="#22ccff";
  querySelector("#dutyTitle").classes.remove("titleDisabled");
  _DutyCycleSlider.disable = false;
  _SweepSlider.disable= false;
}
void _selectSawtooth() {
  querySelector("#sawtoothText").style.color ="#22ccff";
  querySelector("#dutyTitle").classes.remove("titleDisabled");
  _DutyCycleSlider.disable = false;
  _SweepSlider.disable= false;
}
void _selectSine() {
  querySelector("#sineText").style.color ="#22ccff";
  querySelector("#dutyTitle").classes.add("titleDisabled");
  _DutyCycleSlider.disable = true;
  _SweepSlider.disable= true;
}
void _selectTriangle() {
  querySelector("#triangleText").style.color ="#22ccff";
  querySelector("#dutyTitle").classes.add("titleDisabled");
  _DutyCycleSlider.disable = true;
  _SweepSlider.disable= true;
}
void _selectNoise() {
  querySelector("#whiteText").style.color ="#22ccff";
  querySelector("#dutyTitle").classes.add("titleDisabled");
  _DutyCycleSlider.disable = true;
  _SweepSlider.disable= true;
}
void _selectPink() {
  querySelector("#pinkText").style.color ="#22ccff";
  querySelector("#dutyTitle").classes.add("titleDisabled");
  _DutyCycleSlider.disable = true;
  _SweepSlider.disable= true;
}
void _selectBrown() {
  querySelector("#brownText").style.color ="#22ccff";
  querySelector("#dutyTitle").classes.add("titleDisabled");
  _DutyCycleSlider.disable = true;
  _SweepSlider.disable= true;
}

void _play(Event e) {
  _audioMixer.trigger();
}

void _dump(Event e) {
//  Map m = _sfxr.toMapAsSamples(_sfxr.current, _sfxr.category);
//  print(JSON.encode(m));
}

void _dumpAsSettings(Event e) {
  // Settings + Noise buffer
  Map m = _audioMixer.toMapAsSettings();
  print(JSON.encode(m));
  TextAreaElement area = querySelector("#dataId");
  area.text = JSON.encode(m);
  _copyToClipboard();
}

void _pickupCoin(Event e) {
  _resetGenTextStyles();
  _selectPickup();

  _audioMixer.effect.category = Ranger.WASfxr.PICKUP_COIN;
  _audioMixer.effect.name = "${_audioMixer.effect.category}${_nameCount++}";
  _updateFocusField(_audioMixer.effect.name);
  
  _audioMixer.effect.genPickupCoin();
  
  _resetOscTextStyles();
  _selectOscillator(_audioMixer.effect.OscillatorType);

  _updateView(true);
  _audioMixer.trigger();
}

void _laserShoot(Event e) {
  _resetGenTextStyles();
  _selectLaser();
  
  _audioMixer.effect.category = Ranger.WASfxr.LASER_SHOOT;
  _audioMixer.effect.name = "${_audioMixer.effect.category}${_nameCount++}";
  _updateFocusField(_audioMixer.effect.name);
  
  _audioMixer.effect.genLaserShoot();
  
  _resetOscTextStyles();
  _selectOscillator(_audioMixer.effect.OscillatorType);
  
  _updateView(true);
  _audioMixer.trigger();
}

void _explosion(Event e) {
  _resetGenTextStyles();
  _selectExplode();
  
  _audioMixer.effect.category = Ranger.WASfxr.EXPLOSION;
  _audioMixer.effect.name = "${_audioMixer.effect.category}${_nameCount++}";
  _updateFocusField(_audioMixer.effect.name);
  
  _audioMixer.effect.genExplosion();
  
  _resetOscTextStyles();
  _selectOscillator(_audioMixer.effect.OscillatorType);
  
  _updateView(true);
  _audioMixer.trigger();
}

void _powerUp(Event e) {
  _resetGenTextStyles();
  _selectPower();
  
  _audioMixer.effect.category = Ranger.WASfxr.POWERUP;
  _audioMixer.effect.name = "${_audioMixer.effect.category}${_nameCount++}";
  _updateFocusField(_audioMixer.effect.name);
  
  _audioMixer.effect.genPowerUp();
  
  _resetOscTextStyles();
  _selectOscillator(_audioMixer.effect.OscillatorType);
  
  _updateView(true);
  _audioMixer.trigger();
}

void _hitHurt(Event e) {
  _resetGenTextStyles();
  _selectHitHurt();
  
  _audioMixer.effect.category = Ranger.WASfxr.HIT_HURT;
  _audioMixer.effect.name = "${_audioMixer.effect.category}${_nameCount++}";
  _updateFocusField(_audioMixer.effect.name);
  
  _audioMixer.effect.genHitHurt();
  
  _resetOscTextStyles();
  _selectOscillator(_audioMixer.effect.OscillatorType);
  
  _updateView(true);
  _audioMixer.trigger();
}

void _jump(Event e) {
  _resetGenTextStyles();
  _selectJump();
  
  _audioMixer.effect.category = Ranger.WASfxr.JUMP;
  _audioMixer.effect.name = "${_audioMixer.effect.category}${_nameCount++}";
  _updateFocusField(_audioMixer.effect.name);
  
  _audioMixer.effect.genJump();
  
  _resetOscTextStyles();
  _selectOscillator(_audioMixer.effect.OscillatorType);
  
  _updateView(true);
  _audioMixer.trigger();
}

void _blipSelect(Event e) {
  _resetGenTextStyles();
  _selectBlip();
  
  _audioMixer.effect.category = Ranger.WASfxr.BLIP_SELECT;
  _audioMixer.effect.name = "${_audioMixer.effect.category}${_nameCount++}";
  _updateFocusField(_audioMixer.effect.name);
  
  _audioMixer.effect.genBlipSelect();
  
  _resetOscTextStyles();
  _selectOscillator(_audioMixer.effect.OscillatorType);
  
  _updateView(true);
  _audioMixer.trigger();
}

void _alienShips(Event e) {
  _resetGenTextStyles();
  _selectAlienShips();
  
  _audioMixer.effect.category = Ranger.WASfxr.ALIEN_SHIPS;
  _audioMixer.effect.name = "${_audioMixer.effect.category}${_nameCount++}";
  _updateFocusField(_audioMixer.effect.name);
  
  _audioMixer.effect.genAlienShips();
  
  _resetOscTextStyles();
  _selectOscillator(_audioMixer.effect.OscillatorType);
  
  _updateView(true);
  _audioMixer.trigger();
}

void _highAlarms(Event e) {
  _resetGenTextStyles();
  _selectHighAlarms();
  
  _audioMixer.effect.category = Ranger.WASfxr.HIGH_ALARMS;
  _audioMixer.effect.name = "${_audioMixer.effect.category}${_nameCount++}";
  _updateFocusField(_audioMixer.effect.name);
  
  _audioMixer.effect.genHighAlarms();
  
  _resetOscTextStyles();
  _selectOscillator(_audioMixer.effect.OscillatorType);
  
  _updateView(true);
  _audioMixer.trigger();
}

void _lowAlarms(Event e) {
  _resetGenTextStyles();
  _selectLowAlarms();
  
  _audioMixer.effect.category = Ranger.WASfxr.LOW_ALARMS;
  _audioMixer.effect.name = "${_audioMixer.effect.category}${_nameCount++}";
  _updateFocusField(_audioMixer.effect.name);
  
  _audioMixer.effect.genLowAlarms();
  
  _resetOscTextStyles();
  _selectOscillator(_audioMixer.effect.OscillatorType);
  
  _updateView(true);
  _audioMixer.trigger();
}

void _random(Event e) {
  _resetGenTextStyles();
  _selectRandom();
  
  _audioMixer.effect.category = Ranger.WASfxr.RANDOM;
  _audioMixer.effect.name = "${_audioMixer.effect.category}${_nameCount++}";
  _updateFocusField(_audioMixer.effect.name);
  
  _audioMixer.effect.genRandom();
  
  _resetOscTextStyles();
  _selectOscillator(_audioMixer.effect.OscillatorType);
  
  _updateView(true);
  _audioMixer.trigger();
}

void _tone(Event e) {
  _resetGenTextStyles();
  _selectTone();
  
  _audioMixer.effect.category = Ranger.WASfxr.TONE;
  _audioMixer.effect.name = "${_audioMixer.effect.category}${_nameCount++}";
  _updateFocusField(_audioMixer.effect.name);
  
  _audioMixer.effect.genTone();
  
  _resetOscTextStyles();
  _selectOscillator(_audioMixer.effect.OscillatorType);
  
  _updateView(true);
  _audioMixer.trigger();
}

void _mutate(Event e) {
  _audioMixer.effect.mutate();

//  _audio.effect.category = Ranger.WASfxr.MUTATE;
//  if (_audio.effect.name == "") {
//    _audio.effect.name = "${_audio.effect.category}${_nameCount++}";
//    _updateFocusField(_audio.effect.name);
//  }

  _resetOscTextStyles();
  _selectOscillator(_audioMixer.effect.OscillatorType);
  _updateView(true);
  _audioMixer.trigger();
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
  querySelector("#alienShipsText").style.color ="#ffffff";
  querySelector("#highAlarmsText").style.color ="#ffffff";
  querySelector("#lowAlarmsText").style.color ="#ffffff";
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
void _selectAlienShips() {
  querySelector("#alienShipsText").style.color ="#44ffaa";
}
void _selectHighAlarms() {
  querySelector("#highAlarmsText").style.color ="#44ffaa";
}
void _selectLowAlarms() {
  querySelector("#lowAlarmsText").style.color ="#44ffaa";
}
void _selectRandom() {
  querySelector("#randomText").style.color ="#44ffaa";
}
void _selectTone() {
  querySelector("#toneText").style.color ="#44ffaa";
}

void _selectOscillator(String waveShape) {
  if (waveShape == Ranger.WASfxr.SINE)
    _selectSine();
  else if (waveShape == Ranger.WASfxr.SQUARE)
    _selectSquare();
  else if (waveShape == Ranger.WASfxr.SAWTOOTH)
    _selectSawtooth();
  else if (waveShape == Ranger.WASfxr.NOISE)
    _selectNoise();
  else if (waveShape == Ranger.WASfxr.NOISE_PINK)
    _selectPink();
  else if (waveShape == Ranger.WASfxr.NOISE_BROWNIAN)
    _selectBrown();
  else if (waveShape == Ranger.WASfxr.TRIANGLE)
    _selectTriangle();
}

void _selectGenerator(String category) {
  if (category == Ranger.WASfxr.PICKUP_COIN)
    _selectPickup();
  else if (category == Ranger.WASfxr.LASER_SHOOT)
    _selectLaser();
  else if (category == Ranger.WASfxr.EXPLOSION)
    _selectExplode();
  else if (category == Ranger.WASfxr.POWERUP)
    _selectPower();
  else if (category == Ranger.WASfxr.HIT_HURT)
    _selectHitHurt();
  else if (category == Ranger.WASfxr.JUMP)
    _selectJump();
  else if (category == Ranger.WASfxr.BLIP_SELECT)
    _selectBlip();
  else if (category == Ranger.WASfxr.RANDOM)
    _selectRandom();
  else if (category == Ranger.WASfxr.ALIEN_SHIPS)
    _selectAlienShips();
  else if (category == Ranger.WASfxr.HIGH_ALARMS)
    _selectHighAlarms();
  else if (category == Ranger.WASfxr.TONE)
    _selectTone();
}

void _copyToClipboard() {
  TextAreaElement area = querySelector("#dataId");
  area.focus();
  area.select();

  // Doesn't actually work.
  window.document.execCommand("copy", true, "");
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
    _audioMixer.configureWithJSON(m);
    
    // reset mixer panel
    _resetMixerPanel();
    
    _updateView(true);

    _audioMixer.trigger();
  });
  
  reader.readAsText(file);
}