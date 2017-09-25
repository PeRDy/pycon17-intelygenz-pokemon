#!/usr/bin/env python3.6
import os
import shlex
import sys

try:
    from clinner.command import command, Type as CommandType
    from clinner.run import Main
except (ImportError, ModuleNotFoundError):
    import pip

    print('Installing Clinner')
    pip.main(['install', '--user', '-qq', 'clinner'])

    from clinner.command import command, Type as CommandType
    from clinner.run import Main


@command(command_type=CommandType.SHELL_WITH_HELP,
         args=((('-n', '--name',), {'help': 'Docker image name', 'default': 'pycon-pokemon'}),
               (('-f', '--dockerfile'), {'help': 'Dockerfile'})),
         parser_opts={'help': 'Docker build for local environment'})
def build(*args, **kwargs):
    cmd = shlex.split(f'docker build -t {kwargs["name"]}:latest -f Dockerfile .')
    cmd += list(args)
    return [cmd]


@command(command_type=CommandType.SHELL,
         args=((('-n', '--name',), {'help': 'Docker image name', 'default': 'pycon-pokemon'}),
               (('-i', '--interactive'), {'help': 'Run instance interactive', 'action': 'store_true'}),
               (('-p', '--ports'), {'help': 'Docker image tag', 'default': '80:80'}),
               (('--no-nvidia',), {'help': 'Run with docker', 'action': 'store_true'})),
         parser_opts={'help': 'Run application'})
def run(*args, **kwargs):
    app_flag = f'-v {os.getcwd()}:/srv/apps/{kwargs["name"]}/app'
    docker = 'docker' if kwargs['no_nvidia'] else 'nvidia-docker'
    name_flag = f'--name {kwargs["name"]}' if 'name' in kwargs else ''
    ports_flag = f'-p {kwargs["ports"]}'
    interactive_flag = '-it' if kwargs['interactive'] else '-d'
    cmd = shlex.split(f'{docker} run {interactive_flag} {app_flag} {name_flag} {ports_flag} --rm {kwargs["name"]}')
    cmd += list(args)
    return [cmd]


if __name__ == '__main__':
    sys.exit(Main().run())
