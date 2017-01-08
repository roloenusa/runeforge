import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})
socket.connect()
export default socket


function Square(props) {
  return (
    <button className="square" onClick={() => props.onClick()}>
      { props.value }
    </button>
  );
}

class Board extends React.Component {
  renderSquare(i) {
    return <Square key={i} value={this.props.squares[i]} onClick={() => this.props.onClick(i)} />;
  }
  render() {
    const rows = [];
    let t = 0
    for (var j = 0; j < this.props.rows; j++) {
      const cols = [];
      for (var i = 0; i < this.props.cols; i++, t++) {
        cols.push(this.renderSquare(t));
      }
      rows.push(
        <div className="board-row" key={j}>
          {cols}
        </div>
      );
    }


    return (
      <div>
        <div className="status">{status}</div>
        {rows}
      </div>
    );
  }
}

class Game extends React.Component {
  constructor() {
    super();

    const channel = socket.channel("lobby", {});
    channel.join()
      .receive("ok", resp => { console.log("Joined successfully", resp) })
      .receive("error", resp => { console.log("Unable to join", resp) })

    channel.on('new_message', payload => this.testFun(payload));
    channel.on("board_state", payload => this.updateGameState(payload));

    this.state = {
      // Meta Data.
      rows: 10,
      cols: 10,

      // Board State.
      history: [{
        squares: Array(100).fill(null),
      }],
      stepNumber: 0,
      xIsNext: true,

      // Channel Socket.
      channel: channel
    }

    // Get initial state.
    channel.push("board", {});
  }

  jumpTo(step) {
    this.setState({
      stepNumber: step,
      xIsNext: (step % 2) ? false : true,
    })
  }

  handleClick(i) {
    const history = this.state.history;
    const current = history[this.state.stepNumber];
    const squares = current.squares.slice();
    if (calculateWinner(squares) || squares[i]) {
      return;
    }

    squares[i] = this.state.xIsNext ? 'X' : '0';
    this.setState({
      history: history.concat([{
        squares: squares
      }]),
      stepNumber: history.length,
      xIsNext: !this.state.xIsNext
    });
  }

  render() {
    const history = this.state.history;
    const current = history[this.state.stepNumber];
    const winner = calculateWinner(current.squares);

    let status;
    if (winner) {
      status = "Winner is " + winner;
    } else {
      status = 'Next player: ' + (this.state.xIsNext ? 'X' : '0');
    }

    const moves = history.map((step, move) => {
      const desc = move ?
        'move #' + move :
        'Game Start';
      return (
        <li key={move}>
          <a href="#" onClick={() => this.jumpTo(move)}>{desc}</a>
        </li>
      )
    })

    return (
      <div className="game">
        <div className="game-board">
          <Board
            cols={this.state.cols}
            rows={this.state.rows}
            squares={current.squares}
            onClick={(i) => this.handleClick(i)}
          />
        </div>
        <div className="game-info">
          <div>{status}</div>
          <ol>{moves}</ol>
        </div>
      </div>
    );
  }

  testFun(obj) {
    console.log("testing function: ", obj)
  }

  updateGameState(obj) {
    const cols = this.state.cols;
    const rows = this.state.rows;
    const elements = obj.elements;
    // this.setState({elements: elements});
    const squares = Array(cols * rows).fill(null);
    Object.keys(elements).map(key => {
      const el = elements[key];
      squares[(parseInt(el.pos.y*cols) + parseInt(el.pos.x))] = el.character.hp;
    })

    this.setState({
      history: this.state.history.concat([{
        squares: squares
      }]),
      stepNumber: this.state.stepNumber + 1
    });
  }
}

// ========================================

ReactDOM.render(
  <Game />,
  document.getElementById('container')
);

function calculateWinner(squares) {
  const lines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];
  for (let i = 0; i < lines.length; i++) {
    const [a, b, c] = lines[i];
    if (squares[a] && squares[a] === squares[b] && squares[a] === squares[c]) {
      return squares[a];
    }
  }
  return null;
}
