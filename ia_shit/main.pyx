#! /usr/bin/env python
# cython: language_level=3
# distutils: language=c++

""" Purge Repo """

from pathlib                                 import Path
from re                                      import Pattern
import re
from typing                                  import Callable, List, Optional, Iterable

from git                                     import Repo
from git_filter_repo                         import setup_gettext
from git_filter_repo                         import FilteringOptions
#from git_filter_repo                         import RepoAnalyze
from git_filter_repo                         import RepoFilter
from structlog                               import get_logger

from ia_pause.main                           import main as pause_main
from ia_pause.main                           import IndefinitePauseError

logger           = get_logger()
comment:Pattern  = re.compile('^\s*#')

##
#
##

def not_comment(line:str,)->bool:
	return (not comment.match(line))

def _main(*path_globs:str, commit:bool=True,)->None:
	assert path_globs
	assert all((isinstance(path_glob,str) for path_glob in path_globs))

	_args              :List[str]        = [ '--invert-paths', ]
	for path_glob in path_globs:
		logger.debug('appending: %s', path_glob,)
		_args.extend([ '--path-glob', path_glob, ])
	if (not commit):
		_args.insert(0, '--force')

	logger.info('cmd: %s', _args,)
	args               :FilteringOptions = FilteringOptions.parse_args(_args,)
	#if args.analyze:
	#	RepoAnalyze.run(args,)
	#	return
	assert (not args.analyze)
	filter             :RepoFilter       = RepoFilter(args,)
	filter.run()

	# TODO git add remote origin https://...
	# TODO git fetch
	# TODO git branch --set-upstream-to origin/main main
	# TODO git add .
	# TODO git commit -m ...
	# TODO git pull
	# TODO git push

def main()->None:
	commit             :bool      = False # TODO
	if commit:
		repo       :Repo      = Repo()
		repo.git.add(all=True,)
		message    :str       = 'Backup before Obliteration'
		repo.index.commit(message,)
		logger.info('%s', message,)
	else:
		logger.warn('Not creating backup')

	ignore_path        :Path      = Path('.gitignore')
	assert ignore_path.is_file()
	with ignore_path.open('r',) as f:
		ignores    :List[str] = f.readlines()
	assert ignores
	ignores                       = list(filter(not_comment, ignores))
	if (not ignores):
		logger.info('no ignores')
		return
	ignores                       = list(map(str.strip, ignores))

	setup_gettext()
	logger.info('nuking %s globs', len(ignores),)
	logger.debug('to-nuke: %s', '\n'.join(ignores))
	try:
		pause_main()
		_main(*ignores, commit=commit,)
	except IndefinitePauseError as error:
		logger.error(error)

if __name__ == '__main__':
	main()

__author__:str = 'you.com' # NOQA
