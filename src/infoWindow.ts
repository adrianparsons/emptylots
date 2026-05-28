class InfoWindow extends HTMLElement {
  private _data: any = {};

  constructor() {
    super();
    //this.render();
  }

  set data(value: any) {
    this._data = value;
    this.render();
  }

  get data() {
    return this._data;
  }

  private render() {
    const { address, ownername, lotArea, zolaLink, bbl, numPermits, latestPermitDate, numStalledComplaints, vacantSince } = this._data;
    this.innerHTML = `
      <div>
        <h3 style="margin-top: 0">${address || ''}</h3>
        <p>Owner: ${ownername || ''}</p>
        <p>${lotArea || ''} square feet</p>
        ${numPermits > 0 ? `<p>${numPermits} DOB permit${numPermits > 1 ? 's' : ''}${latestPermitDate ? ` (latest: ${latestPermitDate})` : ''}</p>` : ''}
        ${numStalledComplaints > 0 ? `<p>${numStalledComplaints} stalled construction complaint${numStalledComplaints > 1 ? 's' : ''}</p>` : ''}
        ${zolaLink ? `<p><a href="${zolaLink}" target="_blank">ZoLa ⤴</a></p>` : ''}
        ${vacantSince ? `<p>vacant since ${vacantSince.getFullYear()}</p>` : ''}
      </div>
    `;
  }
}

customElements.define('info-window', InfoWindow);