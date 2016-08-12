# ReactiveLocationManager

A ReactiveCocoa 4.x LocationManager written purely in Swift

## Howto

```
ReactiveLocationManager().updates().start { event in 
  switch event {
    case .Next(let location):
      print("You are here: \(location)")
    default:
      break
  }
}
```
