import App from "./app"
import TimeWidget from "./widgets/time"
import JenkinsWidget from "./widgets/jenkins"
import NotepadWidget from "./widgets/notepad"

const widgets = [
TimeWidget,
JenkinsWidget,
NotepadWidget
]

export default {
  run() {
    React.render(<App widgets={widgets}/>, document.body)
  }
}