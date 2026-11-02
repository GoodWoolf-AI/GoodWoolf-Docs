
import React from 'react';
import Link from '@docusaurus/Link';

const categories = [
  {
    label: 'Get Started',
    path: '/introduction',
  },
  {
    label: 'Setup Instructions',
    path: '/environment',
  },
  {
    label: 'Usage Examples',
    path: '/naming-conventions',
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
