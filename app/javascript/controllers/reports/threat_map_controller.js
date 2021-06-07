import { Controller } from 'stimulus'
import jQuery from 'jquery'

export default class extends Controller {
  static targets = ['feed']

  all       = []
  available = []
  rendered  = []

  connect() {
    this.mapEl = jQuery(this.element)

    this.config = JSON.parse(this.data.get('config'))

    Promise.all(JSON.parse(this.data.get('seed')).map((set) => {
      return new Promise((resolve, _reject) => {
        const img = new Image()
        img.src = set.threat.country_flag_url
        img.addEventListener('load', () => {
          this.available.push(set)
          resolve()
        })
      })
    })).then(() => {
      for (let i = 0; i < this.config.renderAmount; i++){
        setTimeout(() => {
          requestAnimationFrame(() => this.renderNext())
        }, 100)
      }
    })

    this.element.addEventListener('geocoded-threat:add', (ev) => {
      const img = new Image()
      img.src = ev.detail.threat.country_flag_url
      img.addEventListener('load', () => {
        this.render(ev.detail, false)
      })
    })

    this.setupMap()
    this.setupGradients()
    this.trimFeed()
  }

  setupMap() {
    this.vecMap = new window.jvm.WorldMap({ container: this.resize(), ...this.config.vectorMap })
    this.vecSvg = window.SVG(this.vecMap.container[0].querySelector('svg'))
  }

  setupGradients() {
    this.gradients = {
      westToEast: this.vecSvg.gradient('linear', stop => {
        stop.at(0, this.config.originColor)
        stop.at(1, this.config.targetColor)
      }),

      eastToWest: this.vecSvg.gradient('linear', stop => {
        stop.at(0, this.config.targetColor)
        stop.at(1, this.config.originColor)
      })
    }
  }

  resize() {
    const height = window.innerHeight

    this.rendered.map((group) => {
      group.attr('style', 'display: none')
      setTimeout(() => {
        requestAnimationFrame(() => this.renderNext())
      }, this.config.fadeOutDelay + 2000)
    })

    return this.mapEl.css({ height })
  }

  render(set, renderNext) {
    const origin      = set.threat
    const target      = set.egress_ip
    const iconOffset  = this.config.iconSize / 2

    const { x: originX, y: originY } = this.vecMap.latLngToPoint(origin.latitude, origin.longitude)
    const { x: targetX, y: targetY } = this.vecMap.latLngToPoint(target.latitude, target.longitude)

    const westToEast = originX > targetX

    const qx  = westToEast ? targetX + ((originX - targetX) / 2) : originX + ((targetX - originX) / 2)
    const qy  = Math.abs(originY - targetY)
    const px1 = westToEast ? originX - iconOffset : originX + iconOffset
    const px2 = westToEast ? targetX + iconOffset : targetX - iconOffset

    const path = this.vecSvg.path(`M ${px1} ${originY - iconOffset} Q ${qx} ${qy} ${px2} ${targetY - iconOffset}`)
      .attr('class', 'attack-path animated-path')
      .attr('style', 'display: none')

    const originIcon = this.vecSvg.image(origin.country_flag_url)
      .attr('x', originX - iconOffset)
      .attr('y', originY - iconOffset)

    const group = this.vecSvg.group()

    group.add(path)
    group.add(originIcon)

    const { node: pathNode } = path
    const dist = pathNode.getTotalLength()
    const dur = `${(dist / this.config.pathRate) * 1000}ms`

    path.attr('stroke', westToEast ? this.gradients.westToEast : this.gradients.eastToWest)
      .attr('stroke-dasharray', dist)
      .attr('stroke-dashoffset', dist)
      .attr('style', `animation-duration: ${dur}`)

    const $path = jQuery(pathNode)
    const $group = jQuery(group.node)

    this.rendered.push(group)
    if (set.rerender == undefined) {
      const priorElements = this.feedTarget.querySelectorAll('[data-detection-date]')

      if (priorElements.length == 0) {
        // First item
        this.feedTarget.insertAdjacentHTML('afterbegin', set.summary)
      } else {
        for (var i = 0; i < priorElements.length; i++) {
          const el = priorElements[i]

          const elDetectionDate = parseFloat(el.getAttribute('data-detection-date'))

          if (elDetectionDate < set.detection_date) {
            el.insertAdjacentHTML('beforebegin', set.summary)
            break
          } else if (i == priorElements.length - 1) {
            this.feedTarget.insertAdjacentHTML('beforeend', set.summary)
          }
        }
      }
    }

    $path.on('animationend', () => {
      group.add(this.vecSvg.image(this.config.targetIconUrl, this.config.iconSize, this.config.iconSize)
        .attr('x', targetX - iconOffset)
        .attr('y', targetY - iconOffset))

      setTimeout(() => {
        $group.addClass('fade-out')
      }, this.config.fadeOutDelay)

      setTimeout(() => {
        $group.remove()

        this.rendered.splice(this.rendered.indexOf(group), 1)
        this.all.push(set)

        if (renderNext) { this.renderNext() }
      }, this.config.fadeOutDelay + 2000)
    })
  }

  renderNext() {
    const nextSet = this.available.shift()

    if (nextSet) this.render(nextSet, true)
    else {
      this.all.forEach((set) => {
        set.rerender = true
        this.available.push(set)
      })

      if (this.available.length > 0) {
        this.render(this.available.shift(), true)
      } else {
        setTimeout(() => { this.renderNext() }, 100)
      }
    }
  }

  trimFeed() {
    if (this.feedTarget.children.length > this.config.maxFeedLength) {
      const child = this.feedTarget.children[this.feedTarget.children.length - 1]
      child.parentElement.removeChild(child)
    }

    requestAnimationFrame(() => this.trimFeed())
  }

  fullscreen() {
    if (this.element.requestFullscreen != undefined) {
      this.element.requestFullscreen()
    } else if (this.element.webkitRequestFullscreen != undefined) {
      this.element.webkitRequestFullscreen()
    }
  }
}
