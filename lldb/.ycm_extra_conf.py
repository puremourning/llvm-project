import os

from ycmd.extra_conf_support import IgnoreExtraConf

def Settings( **kwargs ):
  if kwargs[ 'language' ] == 'python':
    return {
      'sys_path': [
        os.path.join( os.path.dirname( os.path.abspath( __file__ ) ),
                      'packages',
                      'Python' )
      ]
    }

  raise IgnoreExtraConf()
