
```bash
.git/config                              # configuration of remote repositories
git clone <uri>                          # clone a remote repository
git remote add <name> <uri>              # configure a remote repository
git remote -v                            # list remote repositories
git show <name>                          # show remote commit history
git pull <name> <branch>                 # sync branch from remote repository
git push <name> <branch>                 # sync branch to remote repository
```
```bash
git checkout                             # discard changes in working directory
git checkout -- <file>                   # discard changes in file
git checkout <commit> <file>             # checkout specific version of a file
git reset HEAD <file>                    # discard file from staging ares
git reset HEAD --                        # discard all changes in the staging area
git commit --amend                       # alter last commit
git reset --hard                         # discard uncommited changes
git reset --hard <hash>                  # discard until specified commit 
git clean -f                             # recursivly remove file not in version control
GIT_COMMITTER_NAME='<name>' GIT_COMMITTER_EMAIL='<mail>' git commit --author 'name <mail>'
                                          # Set the commiter for a single commit
```
```bach
git clone -b <name> <url>                # clone a remote repository, checkout branch
git branch                               # list local branches
git branch -r                            # list remote branches 
git checkout -b <name> origin/<branch>   # checkout remote branch
git checkout <branch>                    # checkout local branch
git pull --all                           # fetch all remote branches
```
```bash
git ls-remote --tags <repo>              # list tags of remote repository
git fetch                                # fetch remote tags
git tag -l                               # list local tags
git tag -l <regex>                       # list specific tags
git tag -n1 -l                           # list local tags with commit message
git tag -a <version> -m <message>        # create new local tag
git tag -a <version> <hash>              # tag specific commit
git push <name> <tag>                    # push local tag to remote repository
git push --tags <name>                   # push all local tags to remote repository
git tag -l | xargs git tag -d            # delete all local tags
```

```bash
git ls-files -t --exclude-per-directory=.gitignore --exclude-from=.git/info/exclude
                                          # list files
git ls-files --exclude-standard --ignored --others
                                          # list ignored files                            
git log -1 --stat                         # show last commit
git log --pretty=format:"%C(yellow)%h%Cred%d %Creset%s%Cblue (%cn)" --decorate --numstat
                                          # show commits with a list of cahnges files
git log --pretty=format:"%C(yellow dim)%h%Creset %C(white dim)%cr%Creset ─ %s %C(blue dim)(%cn)%Creset"
                                          # list commt messages one by line
git log --follow -p -- <file>             # follow changes to a single file
```

## git-repos

[git-repos][git-repos] helps to solve the following three use-cases:

1. Maintains a list of Git remote repositories associated to a local directory tree. 
2. Indicate the local status for a list of repositories.
3. Indicate the state of remotes for a list of local repositories.

Example output:

    » git repos status -v       
    Reading configuration from ~/.gitrepos
    Git in ~/projects/dummy
    ?? path/to/new/file
    Git in ~/projects/scripts
    ↑1 backup/master
    ↑3 github/master
     M git-repos
    Git in ~/projects/site
    AM posts/git_repos.markdown

_git-repos_ looks for a repository list in `$PWD/.gitrepos`, `~/.gitrepos` or it expects a parameter `--config PATH`. It supports two commands **init** and **status**. Init creates all missing directories defined in the repository list by running `git init` to create an empty repository, followed by executing `git remote add` to configure all defined remote repositories. Status runs `git status -s` on all repositories. Additionally it checks if the local repositories are ahead of their remotes with `git rev-list`. A list of repositories is defined like:

    /path/to/the/repository
      origin git://host.org/project.git
      backup ssh://user@host.org/project.git
    /path/to/another/repository
      name ~/existing/repo
    ~/path/to/yet/another/repo
      foobar ssh://user@host.org/foobar.git
    realitve/path/to/repository
      deploy git://fqdn.com/name.git

Each directory is followed by a list of remotes using the notation of <tt>git remote add</tt>. First the name of the remote, second the URI to the remote repository. 


[git-repos]: ../bin/git-repos
