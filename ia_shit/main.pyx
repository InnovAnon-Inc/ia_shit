#! /usr/bin/env python
# cython: language_level=3
# distutils: language=c++

""" Purge Repo """

import os
from pathlib                                 import Path
from typing                                  import List, Optional, Iterable
from typing                                  import ParamSpec

from git                                     import Repo
from git_filter_repo                         import setup_gettext
from git_filter_repo                         import FilteringOptions
#from git_filter_repo                         import RepoAnalyze
from git_filter_repo                         import RepoFilter
from structlog                               import get_logger

P     :ParamSpec = ParamSpec('P')
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
	commit             :bool      = True
	if commit:
		repo       :Repo      = Repo()
		repo.git.add(all=True,)
		message    :str       = 'Backup before Obliteration'
		repo.index.commit(message,)

	ignore_path        :Path      = Path('.gitignore')
	assert ignore_path.is_file()
	with ignore_path.open('r',) as f:
		ignores    :List[str] = f.readlines()
	logger.info('nuking %s globs', len(ignores),)

	setup_gettext()
	for ignore in ignores:
		_main(path_glob=ignore, commit=commit,)

if __name__ == '__main__':
	main()

__author__:str = 'you.com' # NOQA
