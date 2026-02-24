import os
import json
import re
import logging
import yaml
from pathlib import Path

def setup_logging(log_level):
    """ Setup logging configuration (DEBUG, INFO, WARNING, ERROR, CRITICAL) """

    numeric_level = getattr(logging, log_level.upper(), None)
    logging.basicConfig(level=numeric_level, format='%(asctime)s - %(levelname)s - %(message)s')

def load_infra_config(config_path='.github/actions/tf-matrix/config.yaml'):
    """ Load infrastructure types from YAML config """
    with open(config_path, 'r') as f:
        config = yaml.safe_load(f)
    return config['infra_types']

def get_env_patterns():
    """ Defines regex patterns for each environment """
    infra_config = load_infra_config()

    minor_env = '|'.join(infra_config['minor_infra'])
    major_env = '|'.join(infra_config['major_infra'])

    logging.info("Defining regex patterns for environments.")
    return {
        'base_infra': r'/base/',
        'minor_infra': rf"/overlay/({minor_env})/",
        'major_infra': rf"/overlay/({major_env})/"
    }

def locate_backend_dir(file_path, repo_root=Path('.')):
    """ Traverses upward from the file's directory to locate terraform backend file """

    terraform_backend = 'backend.tf'
    current_dir = Path(file_path)
    logging.info(f"Searching for '{terraform_backend}' starting from {current_dir}.")
    while current_dir != repo_root and current_dir.name:
        if (current_dir / terraform_backend ).exists():
            logging.info(f"'{terraform_backend}' found for {current_dir}.")
            return str(current_dir)
        logging.warning(f"'{terraform_backend}' not found for {current_dir}.")
        current_dir = current_dir.parent
    return None

def group_changed_dirs_by_env(changed_dirs, env_patterns):
    """ Groups changed directories into environments based on regex patterns """

    logging.info("Grouping changed directories by environment.")
    env = {key: set() for key in env_patterns}
    logging.info(f"Initialized env mapping '{env}'.")
    for file_path in changed_dirs:
        logging.info(f"Processing file path: {file_path}")
        for env_key, pattern in env_patterns.items():
            if re.search(pattern, file_path):
                logging.info(f"File path '{file_path}' matches environment '{env_key}'.")
                backend_dir = locate_backend_dir(file_path)
                if backend_dir:
                    env[env_key].add(backend_dir)
                    logging.info(f"Added backend directory '{backend_dir}' to environment '{env_key}'.")
                break
    return env

def write_to_github_output(env, output_file=os.getenv('GITHUB_OUTPUT')):
    """ Writes the environment-detected directories to the GitHub output file """

    logging.info(f"Writing environment-detected directories to GitHub output file: {output_file}.")
    env_json = {key: list(paths) for key, paths in env.items()}
    with open(output_file, 'a') as github_output:
        for key, paths in env_json.items():
            line = f"{key}={json.dumps(paths)}\n"
            github_output.write(line)
            logging.info(f"Written to GitHub output file: {line.strip()}")

def main():
    """ Main execution function """
    setup_logging(os.getenv('LOG_LEVEL'))
    changed_dirs = os.getenv('CHANGED_DIR', "").split()
    env_patterns = get_env_patterns()
    env = group_changed_dirs_by_env(changed_dirs, env_patterns)
    write_to_github_output(env)

if __name__ == "__main__":
    main()
