import App from "./app"
import TimeWidget from "./widgets/time"
import JenkinsWidget from "./widgets/jenkins"

export default {
  run() {
    React.render(<App widgets={[TimeWidget, JenkinsWidget]}/>, document.body)
  }
}