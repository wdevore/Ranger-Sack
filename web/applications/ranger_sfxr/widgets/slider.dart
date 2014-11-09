part of rangersfxr;

class Slider {
  RangeInputElement _slider;
  SpanElement _text;
  bool _mouseDown = false;
  Function _onSlide;
  Function _change;
  
  Slider();
  
  factory Slider.basic(RangeInputElement e, SpanElement t, Function onChange, Function onSlide) {
    Slider s = new Slider();
    
    s._slider = e;
    s._text = t;
    s._onSlide = onSlide;
    s._change = onChange;
    
    // When the mouse is released
    s._slider.onChange.listen((Event e) => s._onChange());

    s._slider.onMouseMove.listen((Event e) => s._mouseMove());
    s._slider.onMouseDown.listen((Event e) => s._mouseDown = true);
    s._slider.onMouseUp.listen((Event e) => s._mouseDown = false);
    
    return s;
  }
  
  void _onChange() {
    _change();
  }
  
  void _mouseMove() {
    if (_mouseDown) {
      _onSlide();
    }
  }
  
  set disable(bool b) {
    _slider.disabled = b;
  }
  set text(String s) => _text.text = s;
  
  double get doubleValue => double.parse(value);
  set doubleValue(double v) => value = v.toString();
  
  set value(String v) => _slider.value = v;
  String get value => _slider.value;
  
}