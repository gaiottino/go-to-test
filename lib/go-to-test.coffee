fs = require 'fs'
path = require 'path'

PATTERNS = [
  [/^lib\/(.*\/)([^\/]+)\.(\w+)$/, ['spec/$1$2_spec.$3', 'spec/$1$2-spec.$3', 'test/$1$2.$3', 'tests/$1$2.$3']],
  [/^(?:spec|tests?)\/(.*\/)([^\/]+?)(?:_spec|-spec|)\.(\w+)$/, ['lib/$1$2.$3']]
]

module.exports =
  activate: (state) ->
    atom.commands.add 'atom-text-editor',
      'go-to-test:toggle': (e) => @toggle(e)

  toggle: (e) ->
    editor = atom.workspace.getActiveTextEditor()
    active_path = atom.project.relativize(editor.getPath())

    for [pattern, productions] in PATTERNS
      for production in productions
        if pattern.test(active_path)
          candidate_path = active_path.replace(pattern, production)
          for project_root in atom.project.getPaths()
            full_path = path.join(project_root, candidate_path)
            if fs.existsSync(full_path)
              atom.workspace.open(full_path)
              return
