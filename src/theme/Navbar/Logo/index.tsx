import React from 'react';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import useBaseUrl from '@docusaurus/useBaseUrl';

export default function Logo() {
  const { siteConfig } = useDocusaurusContext();

  const blackLogo = useBaseUrl('/img/logo_black.svg');
  const whiteLogo = useBaseUrl('/img/logo_white.svg');

  return (
    <a href="/" target="_self" className="navbar__brand">
      <img
        src={blackLogo}
        alt="GoodWoolf"
        className="navbar__logo light-logo"
        style={{ height: '50px', width: 'auto' }}
      />
      <img
        src={whiteLogo}
        alt="GoodWoolf"
        className="navbar__logo dark-logo"
        style={{ height: '50px', width: 'auto' }}
      />
    </a>
  );
}