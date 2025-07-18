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


algo() {
    if [ $# -ne 1 ]; then
         echo "Usage: run_java_with_input <input_file.txt>"
         return 1
     fi
    
     input_file=$1
    
     # Compile Main.java
     javac Main.java
     if [ $? -ne 0 ]; then
         echo "Compilation failed"
         return 1
     fi
    
     # Read input and answer from the file
     input=$(sed -e '/^$/q' "$input_file")
     answer=$(sed -e '1,/^$/d' "$input_file")
    
     # Run the program with input and capture output
     output=$(echo "$input" | java Main)
    
     # Print output and answer
     echo "output:"
     echo "$output"
     echo "answer:"
     echo "$answer"
 }


startAlgo() {
  local target="Main.java"
  cat << 'EOF' > "$target"
import java.io.*;
import java.util.*;
\n
class Main {
  static BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
  static BufferedWriter bw = new BufferedWriter(new OutputStreamWriter(System.out));
  public static void main(String[] args) throws IOException {
    StringTokenizer st = new StringTokenizer(br.readLine());
  }
}
EOF
  echo "Created: $PWD/$target"
}

