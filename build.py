#!/usr/bin/env python3




import sys, os, logging, argparse, shutil, re, json
from docker import Client
from tempfile import gettempdir



tmp_build_dir="%s/docker_build_dir" % gettempdir()



def setup_logging():
  
  root_handler = logging.StreamHandler(sys.stdout)
  root_formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
  root_handler.setFormatter(root_formatter)
  
  root_logger = logging.getLogger();
  root_logger.addHandler(root_handler)
  root_logger.setLevel(logging.DEBUG)
  


  #ch = logging.StreamHandler(sys.stdout)
  #ch.setLevel(logging.DEBUG)
  #formatter = logging.Formatter('%(asctime)s DOCKER: %(message)s')
  #ch.setFormatter(formatter)
  
  #docker_logger = logging.getLogger('docker')
  #docker_logger.addHandler(ch)
  #docker_logger.setLevel(logging.DEBUG)

def set_logging_level( level ):

  root_logger = logging.getLogger();
  root_logger.setLevel(level)






def create_build_copy( src_build_dir, tmp_build_dir=None ):
  if not tmp_build_dir:
    tmp_build_dir = tempfile.mkdtemp(prefix='docker_build_x_')
  logging.debug("copy build dir from %s to %s" % (src_build_dir, tmp_build_dir))
  shutil.copytree(src_build_dir, tmp_build_dir)
  return tmp_build_dir


def remove_build_copy( tmp_build_dir ):
  logging.debug("remove build dir at %s" % tmp_build_dir)
  shutil.rmtree(tmp_build_dir)




def dockerfile_get_FROM( dockerfile ):
  with open(dockerfile, 'r') as fin:
    dockerfile_contents = fin.read()
    tag_matches = re.search(r'FROM (?P<image>[^\s:]+)(?::(?P<tag>[^\s]+))?', dockerfile_contents)
    if not tag_matches:
      return None
    return tag_matches.groupdict({'image':None, 'tag':None})


def dockerfile_set_FROM( dockerfile, image, tag=None ):
  import fileinput
  fromRegEx = re.compile(r'FROM [^\s:]+(?::[^\s]+)?')
  
  if tag:
    FROM = "%s:%s" % (image,tag)
  else:
    FROM = "%s" % (image)
  
  
  with open(dockerfile, 'r') as f:
    contents = f.read()
    contents = fromRegEx.sub('FROM %s' % FROM, contents, 1)
    f.close()
      
  with open(dockerfile, 'w') as f:
    f.write(contents)
    f.close()
  
  logging.info("Set Dockerfile FROM %s" % FROM)




def docker_build( build_dir, tag="cyledge/base", dockerfile="Dockerfile", pull_first=True, use_cache=True, quiet=False):

  logger = logging.getLogger("docker")
  logging.info("Building docker image %s" % tag)
  
  if pull_first:
    logging.debug("Pulling FROM image first")
  if not use_cache:
    logging.debug("Not using cache")
  
  
  #dockerfile = "%s/%s" % (build_dir, dockerfile)
  
  c = Client(base_url='unix://var/run/docker.sock')
  build_output = c.build(
    path=build_dir,
    dockerfile=dockerfile,
    tag=tag,
    stream=True,
    quiet=quiet,
    pull=pull_first,
    nocache= not use_cache
    )

  last_line = None
  for line in build_output:
    output = json.loads(line.decode('UTF-8'))
    if "stream" in output:
      logger.debug(output["stream"].rstrip())
      last_line = output["stream"]
    if "error" in output:
      logger.error(output["error"].rstrip())
      #logger.error(output["errorDetail"])
    
  if quiet:
    srch = r'sha256:([0-9a-f]{12})[0-9a-f]+'
  else:
    srch = r'Successfully built ([0-9a-f]{12})'
  match = re.search(srch, last_line)
  if not match:
    raise RuntimeError()
  else:
    return match.group(1)
    


def docker_push( image, tag='latest' ):


  logger = logging.getLogger("docker")
  logging.info("Pushing docker image %s:%s" % (image, tag))
  
  #dockerfile = "%s/%s" % (build_dir, dockerfile)
  
  c = Client(base_url='unix://var/run/docker.sock')
  docker_output_stream = c.push(
    image,
    tag=tag,
    stream=True
    )

  pushed_images = []
  last_line = ""
  for line in docker_output_stream:
    output = json.loads(line.decode('UTF-8'))
    if "status" in output:
      if output["status"] == "Image already exists":
        continue
      logger.debug("D: %s" % output["status"].rstrip())
      last_line = output["status"]
    if "error" in output:
      logger.error(output["error"].rstrip())
      #logger.error(output["errorDetail"])
    if not "status" in output:
      logger.debug("unknown output: %s" % output)
  
  srch = r'%s: digest: (sha256:[0-9a-fA-F]+) size: [\d]+' % re.escape(tag)
  match = re.search(srch, last_line)
  if not match:
    raise RuntimeError()
  else:
    return match.group(1)
 



def build_base_image( build_dir, ubuntu_release, pull_first=True, quiet=False ):
  
  image_tag = "cyledge/base:%s" % ubuntu_release
  
  try:
    create_build_copy(build_dir, tmp_build_dir)
    dockerfile_set_FROM(tmp_dockerfile, "ubuntu", ubuntu_release)
    real_from = dockerfile_get_FROM(tmp_dockerfile)
    
    docker_build(tmp_build_dir, tag=image_tag, pull_first=pull_first, quiet=quiet)
    
    logging.info("build complete")
  except RuntimeError as e:
    import traceback
    logging.error("faild to build image")
    traceback.print_tb(e.__traceback__)
  except Exception as e:
    import traceback
    logging.error("faild to build image")
    traceback.print_tb(e.__traceback__)
    raise
  finally:
    remove_build_copy(tmp_build_dir)
  


def push_base_image( ubuntu_release ):
  
  docker_push( "cyledge/base", ubuntu_release )




if __name__ == '__main__':
  
  setup_logging()
  
  if (sys.version_info < (3, 0)):
    logging.error("This script requires python version 3")
    sys.exit(1)
    
  
  current_directory = os.path.dirname( os.path.abspath(__file__) )
  default_build_dir = "%s/image" % current_directory
  
  parser = argparse.ArgumentParser(description='Docker image builder.')
  parser.add_argument('--dir', '-d', default=default_build_dir, help="Build directory to use (default: ./image)")
  parser.add_argument('--release', '-r', default="18.04", help="Ubuntu release to build from (default: 18.04)")
  parser.add_argument('--no-pull', dest='pull', action='store_false', help="Prevent pull of Ubuntu release image before build")
  parser.add_argument('--quiet', '-q', dest='quiet', action='store_true', help="Disable verbose output during docker build")
  
  parser.add_argument('command', choices=['build', 'push'], default="build", nargs='?',
		      help="Command to run (default: build)")
  
  args = parser.parse_args()
  
  
  if args.quiet:
    set_logging_level( logging.INFO )
  
  tmp_dockerfile = "%s/Dockerfile" % tmp_build_dir
  
  if os.path.exists(tmp_build_dir):
    logging.error("Temporary build dir already exists. Maybe another build process is currently running..");
    logging.error("Restart once the directory %s does not exist anymore" % tmp_build_dir);
    sys.exit(1)
  
  if not os.path.exists( args.dir ):
    logging.error("Build directory not found: %s" % args.dir)
    sys.exit(1)
  
  if not os.path.exists( "%s/Dockerfile" % args.dir ):
    logging.error("Build directory does not contain a Dockerfile")
    sys.exit(1)
  
  
  if args.command == "build":
    build_base_image( args.dir, args.release, pull_first=args.pull, quiet=args.quiet )
  elif args.command == "push":
    push_base_image( args.release )
  else:
    logging.error("Unknown command: %s" % args.command)
    sys.exit(1)
  
  
  
  
  
