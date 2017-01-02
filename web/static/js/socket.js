// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
// let channel = socket.channel("topic:subtopic", {})
// channel.join()
//   .receive("ok", resp => { console.log("Joined successfully", resp) })
//   .receive("error", resp => { console.log("Unable to join", resp) })

export default socket

/**
 * Socket stuff:
 */
 let channel = socket.channel("lobby", {});
 let list    = $('#message-list');
 let message = $('#message');
 let name    = $('#name');

message.on('keypress', event => {
  if (event.keyCode == 13) {
    channel.push('new_message', { name: name.val(), message: message.val() });
    message.val('');
  }
});

channel.on('new_message', payload => {
  list.append(`<b>${payload.name || 'Anonymous'}:</b> ${payload.message}<br>`);
  list.prop({scrollTop: list.prop("scrollHeight")});
});

channel.on("board_state", payload => {
    console.log("Payload: ", payload)
    drawGrid(payload)
});

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.push('board', {});

function drawGrid(payload) {
  let grid = $("#grid");
  grid.empty();

  let chars = payload.elements
  $.each(chars, function(id, elem){
    console.log(elem.character.name);
    grid.append(`<div id="${id}" class="row form-group"></div>`);
    let div = $(`#${id}`);

    div.append(`
      <div class="col-md-3">${elem.character.name}</div>
      <div class="col-md-2">${elem.character.hp}</div>
      <div class="col-md-2">${elem.character.bloodied}</div>
      <div class="col-md-2">
        <input type="text" id="${id}_posX" value="${elem.pos.x}" class="form-control"/>
      </div>
      <div class="col-md-2">
        <input type="text" id="${id}_posY" value="${elem.pos.y}" class="form-control"/>
      </div>
      <div class="col-md-1">
        <button id="go_${id}">Go!</button>
      </div>
    `);

    let button = $(`#go_${id}`)
    button.click(payload => {
      console.log("pushing payload: ", payload);
      let pos_x = $(`#${id}_posX`).val();
      let pos_y = $(`#${id}_posY`).val();
      channel.push('move', { id: id, name: "hello", pos: {x: pos_x, y: pos_y} });
    });
  });
}
