function title_align_left(iText,varargin)
    t = title(iText,'horizontalAlignment', 'left',varargin{:});
    h = get(t, 'position'); set(t, 'position', [0 h(2) h(3)]);
end