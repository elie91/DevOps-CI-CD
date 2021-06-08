/*global Vue, todoStorage */

(function (exports) {

	'use strict';

	let filters = {
		all: function (todos) {
			return todos;
		},
		active: function (todos) {
			return todos.filter(function (todo) {
				return !todo.checked;
			});
		},
		completed: function (todos) {
			return todos.filter(function (todo) {
				return todo.checked;
			});
		}
	};

	exports.app = new Vue({

		// the root element that will be compiled
		el: '.todoapp',

		// app initial state
		data: {
			todos: [],
			newTodo: '',
			editedTodo: null,
			visibility: 'all'
		},

		// watch todos change for localStorage persistence
		watch: {
			todos: {
				deep: true,
				handler: todoStorage.save
			}
		},

		// computed properties
		// http://vuejs.org/guide/computed.html
		computed: {
			filteredTodos: function () {
				return filters[this.visibility](this.todos);
			},
			remaining: function () {
				return filters.active(this.todos).length;
			},
			allDone: {
				get: function () {
					return this.remaining === 0;
				},
				set: function (value) {
					this.todos.forEach(function (todo) {
						todo.checked = value;
					});
				}
			}
		},

		// methods that implement data logic.
		// note there's no DOM manipulation here at all.
		methods: {

			pluralize: function (word, count) {
				return word + (count === 1 ? '' : 's');
			},

			addTodo: async function () {

				const config = await(await fetch('./config.json')).json();
				let value = this.newTodo && this.newTodo.trim();
				if (!value) {
					return;
				}
				fetch(config.backendUrl, {
					method: 'POST',
					body: JSON.stringify({
						content: value,
					})
				})
				.then(response => response.json())
				.then(data => {
					data = JSON.parse(data);
					this.todos.push({ id: data.id, content: data.content, checked: data.checked });
				});
				this.newTodo = '';
			},

			removeTodo: async function (todo) {
				const config = await(await fetch('./config.json')).json();
				fetch(config.backendUrl+todo.id, {
					method: 'DELETE',
				})
				.then((response) => {
					if (response.ok){
						const index = this.todos.indexOf(todo)
						this.todos.splice(index, 1)
					}
				});
			},

			editTodo: function (todo) {
				this.beforeEditCache = todo.content;
				this.editedTodo = todo;
			},

			checkTodo: async function (todo){
				const config = await(await fetch('./config.json')).json();
				fetch(config.backendUrl+todo.id, {
					method: 'PUT',
					body: JSON.stringify({
						checked: todo.checked,
					})
				}).then(() => console.log("Checked"))
			},

			doneEdit: async function (todo) {
				if (!this.editedTodo) {
					return;
				}
				this.editedTodo = null;
				todo.content = todo.content.trim();

				const config = await(await fetch('./config.json')).json();

				if (todo.content.length > 0){
					fetch(config.backendUrl+todo.id, {
						method: 'PUT',
						body: JSON.stringify({
							content: todo.content,
						})
					}).then(() => {
						todo.content = todo.content.trim();
					})
				}

				if (!todo.content) {
					fetch(config.backendUrl+todo.id, {
						method: 'DELETE',
					})
					.then((response) => {
						if (response.ok){
							this.removeTodo(todo);
						}
					});
				}
			},

			cancelEdit: function (todo) {
				this.editedTodo = null;
				todo.content = this.beforeEditCache;
			},

			removeCompleted: function () {
				this.todos = filters.active(this.todos);
			}
		},

		// a custom directive to wait for the DOM to be updated
		// before focusing on the input field.
		// http://vuejs.org/guide/custom-directive.html
		directives: {
			'todo-focus': function (el, binding) {
				if (binding.value) {
					el.focus();
				}
			}
		},
		created: function () {
			todoStorage.fetch().then(todos => { this.todos = JSON.parse(todos); });
		}
	});

})(window);
