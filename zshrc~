alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gb='git branch'
alias setCommitTemplate='git config commit.template /Users/skull/Documents/project/repository/.gitmessage.txt'
alias build='./gradlew clean build'

gitBrachGraph(){
    command git log --all --decorate --oneline --graph
}

makeBranch(){
    if [ "$#" -ne 2 ]; then
        echo "Error: 함수는 2개의 인자를 필요로 합니다."
        echo "사용법: $0 arg1 arg2"
    else
        from=$1
        to=$2
        git checkout $from
        git pull
        git checkout -b $to
        echo new branch $to made
    fi
}

changeBranch() {
    if [ "$#" -ne 2 ]; then
        echo "Error: 함수는 2개의 인자를 필요로 합니다."
        echo "사용법: $0 arg1 arg2"
    else
        from=$1
        to=$2
        git checkout $from
        git pull
        git checkout $to
        echo git branch changed from $from to $to
    fi
}

gitCommit(){
    git add .
    git commit
}

