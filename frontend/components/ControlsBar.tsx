'use client'

export type FilterType = 'all' | 'with-infections'
export type SortType = 'id-asc' | 'id-desc' | 'infections-desc' | 'infections-asc'

interface ControlsBarProps {
  filter: FilterType
  sort: SortType
  totalSupply: number
  totalInfections: number
  onFilterChange: (filter: FilterType) => void
  onSortChange: (sort: SortType) => void
}

export function ControlsBar({
  filter,
  sort,
  totalSupply,
  totalInfections,
  onFilterChange,
  onSortChange,
}: ControlsBarProps) {
  return (
    <div className="controls-bar">
      <div className="controls-left">
        <button
          className={`btn-secondary btn-small ${filter === 'all' ? 'active' : ''}`}
          onClick={() => onFilterChange('all')}
        >
          ALL
        </button>
        <button
          className={`btn-secondary btn-small ${filter === 'with-infections' ? 'active' : ''}`}
          onClick={() => onFilterChange('with-infections')}
        >
          WITH INFECTIONS
        </button>

        <div
          style={{
            borderLeft: '1px solid #e8e8e8',
            height: '30px',
            margin: '0 5px',
          }}
        />

        <select value={sort} onChange={(e) => onSortChange(e.target.value as SortType)}>
          <option value="id-asc">SORT: ID (OLDEST FIRST)</option>
          <option value="id-desc">SORT: ID (NEWEST FIRST)</option>
          <option value="infections-desc">SORT: CONTAMINATION (HIGH→LOW)</option>
          <option value="infections-asc">SORT: CONTAMINATION (LOW→HIGH)</option>
        </select>
      </div>

      <div className="controls-right">
        <div className="stats-inline">
          <div className="stat-inline">
            <span>SPREADERS:</span>
            <span className="stat-inline-value">{totalSupply}</span>
          </div>
          <div className="stat-inline">
            <span>INFECTIONS:</span>
            <span className="stat-inline-value">{totalInfections}</span>
          </div>
        </div>
      </div>
    </div>
  )
}
