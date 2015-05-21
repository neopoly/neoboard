import App from "./app"
import TimeWidget from "./widgets/time"
import JenkinsWidget from "./widgets/jenkins"
import NotepadWidget from "./widgets/notepad"
import NichtLustigWidget from "./widgets/nicht_lustig"
import RedmineProjectTable from "./widgets/redmine_project_table"
import Gitter from "./widgets/gitter"
import RedmineActivityProjects from "./widgets/redmine_activity_projects"
import RedmineActivityUsers from "./widgets/redmine_activity_users"
import OwncloudImages from "./widgets/owncloud_images"
import Images from "./widgets/images"

const widgets = [
Gitter,
RedmineActivityProjects,
RedmineActivityUsers,
OwncloudImages,
TimeWidget,
JenkinsWidget,
NichtLustigWidget,
RedmineProjectTable,
NotepadWidget,
Images
]

export default {
  run() {
    React.render(<App widgets={widgets}/>, document.body)
  }
}