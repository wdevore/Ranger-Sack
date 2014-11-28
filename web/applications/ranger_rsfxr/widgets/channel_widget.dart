part of ranger_rsfxr;

class ChannelWidget {
  DivElement _container;
  Slider _gain;
  Slider _delay;
  
  CheckboxInputElement _enable;
  RadioButtonInputElement _active;

  RangeInputElement _gainRange;
  SpanElement _gainSpan;

  RangeInputElement _delayRange;
  SpanElement _delaySpan;
  DivElement container;

  String radioName = "channel";
  
  Function callback;
  
  static int _id = 0;
  int index;
  
  ChannelWidget();

  factory ChannelWidget.basic() {
    ChannelWidget s = new ChannelWidget();
    
    if (s.init())
      return s;
    
    return null;
  }

  bool init() {
    index = _id++;
    
    container = new DivElement();
    container.classes.add("channelContainer");
    
    _enable = new CheckboxInputElement();
    container.append(_enable);
    _enable.onClick.listen((Event e) => _enableChecked());

    _active = new RadioButtonInputElement();
    _active.name = radioName;
    container.append(_active);
    _active.onClick.listen((Event e) => _activeChecked());
    
    _gainRange = new RangeInputElement();
    _gainRange.classes.add("channelGain");
    _gainRange.min = "0.0";
    _gainRange.max = "2.0";
    _gainRange.value = "1.0";
    _gainRange.step = "0.001";
    _gainSpan = new SpanElement();
    _gainSpan.text = "Gain";
    _gain = new Slider.basic(_gainRange, _gainSpan, _onGainChange, _onGainSlide); 
    container.append(_gainRange);
    container.append(_gainSpan);
    
    SpanElement span = new SpanElement();
    span.classes.add("channelSpanDelay");
    _delayRange = new RangeInputElement();
    _delayRange.min = "0.0";
    _delayRange.max = "2.0";
    _delayRange.value = "0.0";
    _delayRange.step = "0.001";
    _delayRange.classes.add("channelDelay");
    _delaySpan = new SpanElement();
    _delaySpan.text = "Delay";
    _delay = new Slider.basic(_delayRange, _delaySpan, _onDelayChange, _onDelaySlide); 
    span.append(_delayRange);
    span.append(_delaySpan);
    container.append(span);
    
    return true;
  }
  
  set gain(double g) => _gain.doubleValue = g;
  set delay(double t) => _delay.doubleValue = t;
  set enabled(bool b) => _enable.checked = b;
  
  void setActive() {
    _active.checked = true;
  }
  
  void _activeChecked() {
    callback(index, "ActiveChecked", _enable.checked, _active.checked, _gain.doubleValue, _delay.doubleValue);
  }
  
  void _enableChecked() {
    callback(index, "EnableChecked", _enable.checked, _active.checked, _gain.doubleValue, _delay.doubleValue);
  }
  
  void _onGainChange() {
    callback(index, "GainChange", _enable.checked, _active.checked, _gain.doubleValue, _delay.doubleValue);
  }
  
  void _onGainSlide() {
    callback(index, "GainSlide", _enable.checked, _active.checked, _gain.doubleValue, _delay.doubleValue);
  }

  void _onDelayChange() {
    callback(index, "DelayChange", _enable.checked, _active.checked, _gain.doubleValue, _delay.doubleValue);
  }
  
  void _onDelaySlide() {
    callback(index, "DelaySlide", _enable.checked, _active.checked, _gain.doubleValue, _delay.doubleValue);
  }
}