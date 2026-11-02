
import React from 'react';
import Link from '@docusaurus/Link';

const categories = [
  {
    label: 'Get Started',
    path: '/get-started/intro',
  },
  {
    label: 'Tutorial Basics',
    path: '/tutorial-basics/create-a-page',
  },
  {
    label: 'Tutorial Extras',
    path: '/tutorial-extras/manage-docs-versions',
  },
];

export default function DocsCategories(): React.ReactElement {
  return (
    <div className="row">
      {categories.map((category) => (
        <div
          className="col col--6 margin-bottom--lg"
          key={category.path}
        >
          <div className="card">
            <div className="card__header">
              <h3>{category.label}</h3>
            </div>

            <div className="card__body">
              <Link to={category.path}>
                Explore category →
              </Link>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
