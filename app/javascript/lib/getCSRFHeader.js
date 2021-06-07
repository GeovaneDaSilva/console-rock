import { DeveloperError } from './errors/DeveloperError'

class MissingCSRFHeaderContent extends DeveloperError {
  constructor(msg) {
    super(msg)
  }
}

export const getCSRFHeader = () => {
  const csrfHeaderName = document.querySelector('meta[name="csrf-param"]').content
  const csrfHeaderValue = document.querySelector('meta[name="csrf-token"]').content

  if (!csrfHeaderName) {
    throw new MissingCSRFHeaderContent('Could not find header parameter name in the document markup.')
  }

  if (!csrfHeaderName) {
    throw new MissingCSRFHeaderContent('Could not find header value in the document markup.')
  }

  return {
    csrfHeaderName,
    csrfHeaderValue,
  }
}
