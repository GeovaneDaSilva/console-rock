import ActionCable from 'actioncable'

const consumer = ActionCable.createConsumer()

export { consumer as Cable }
