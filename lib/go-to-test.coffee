fs = require 'fs'

module.exports =
  activate: (state) ->
    atom.workspaceView.command 'go-to-test:toggle', '.editor', @toggle

  toggle: (e) ->
    editor = atom.workspace.getActiveTextEditor()
    path = atom.project.relativize(editor.getPath())
    if path.indexOf('lib/') == 0
      new_path = path.replace(/^lib/, 'spec').replace(/(\.\w+)$/, '_spec$1')
      for project_root in atom.project.getPaths()
        full_path = project_root + '/' + new_path
        if fs.existsSync(full_path)
          atom.workspace.open(full_path)
    else if path.indexOf('spec/') == 0
      new_path = path.replace(/^spec/, 'lib').replace(/_spec(\.\w+)$/, '$1')
      for project_root in atom.project.getPaths()
        full_path = project_root + '/' + new_path
        if fs.existsSync(full_path)
          atom.workspace.open(full_path)
