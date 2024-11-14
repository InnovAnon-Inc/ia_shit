#! /usr/bin/env python
# cython: language_level=3
# distutils: language=c++

""" Purge Repo """

from pathlib                                 import Path
from re                                      import Pattern
import re
from typing                                  import List, Optional, Iterable

from git                                     import Repo
from git_filter_repo                         import setup_gettext
from git_filter_repo                         import FilteringOptions
#from git_filter_repo                         import RepoAnalyze
from git_filter_repo                         import RepoFilter
from structlog                               import get_logger

from ia_pause.main                           import main as pause_main

logger           = get_logger()

##
#
##

def _main(path_glob:str, commit:bool,)->None:
	logger.warn('nuking: %s', path_glob,)
	_args              :List[str] = [
		'--invert-paths',
		'--path-glob', path_glob,
	]
	if (not commit):
		_args.insert(0, '--force')
	args                          = FilteringOptions.parse_args(_args,)
	#if args.analyze:
	#	RepoAnalyze.run(args,)
	#	return
	assert (not args.analyze)
	filter                        = RepoFilter(args,)
	filter.run()

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
	logger.info('nuking %s globs', len(ignores),)
	logger.debug('to-nuke: %s', '\n'.join(ignores))
	pause_main()

	setup_gettext()
	comment:Pattern = re.compile('^[[:space:]]*#')
	for ignore in ignores:
		if comment.match(ignore):
			logger.debug('comment: %s', ignore,)
			continue
		_main(path_glob=ignore, commit=commit,)

if __name__ == '__main__':
	main()

__author__:str = 'you.com' # NOQA
