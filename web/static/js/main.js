import App from "./app"
import TimeWidget from "./widgets/time"

export default {
  run() {
    React.render(<App widgets={[TimeWidget]}/>, document.body)
  }
}