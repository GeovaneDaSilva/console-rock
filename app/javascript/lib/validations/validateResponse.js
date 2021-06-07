import { inRange } from 'lodash'
import { DeveloperError } from '../errors/DeveloperError'
import { ClientError } from '../errors/ClientError'
import { ResponseError } from '../errors/ResponseError'

export const validateResponse = (response) => {
  if (inRange(response.status, 400, 500)) {
    const error = new ResponseError(response)
    switch (response.status) {
    case 400: {
      throw new DeveloperError('Client sent an invalid request')
        .setAsRoot()
        .setCausedBy(error)
    }
    case 401: {
      throw new ClientError('Unable to authorize client')
        .setAsRoot()
        .setCausedBy(error)
        .setClientMessage('It looks like your authorization has expired. Please try signing out of RocketCyber, signing in again, and trying this again.')
    }
    // TODO: add additional error types here
    default: {
      throw new DeveloperError('Bad Request')
        .setAsRoot()
        .setCausedBy(error)
    }
    }
  }
  if (inRange(response.status, 500, 600)) {
    const error = new ResponseError(response)
    switch(response.status) {
    case 502: {
      throw new DeveloperError('502 Bad Gateway: Server is unavailable or response is invalid')
        .setAsRoot()
        .setCausedBy(error)
        .setClientMessage('It looks like our servers are working really hard at the moment. We can\'t complete your request right now, but we\'ve been notified. In the meantime, please try again in a few minutes.')
    }
    // TODO: add additional error types here
    default: {
      throw new DeveloperError('An error occurred on the server')
        .setAsRoot()
        .setCausedBy(error)
    }
    }
  }
}
