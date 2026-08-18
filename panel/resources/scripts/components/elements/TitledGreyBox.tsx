import React, { memo } from 'react';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import tw from 'twin.macro';
import styled from 'styled-components/macro';
import isEqual from 'react-fast-compare';

interface Props {
    icon?: IconProp;
    title: string | React.ReactNode;
    className?: string;
    children: React.ReactNode;
}

const Box = styled.div`
    background: linear-gradient(150deg, #2b3644 0%, #212a35 100%);
    border: 1px solid #38495a;
    border-top: 3px solid #3c8dbc;
    box-shadow: 0 6px 18px rgba(0, 0, 0, 0.22);
    ${tw`rounded-lg overflow-hidden`};
    transition: border-color 0.15s ease, box-shadow 0.15s ease;

    &:hover {
        border-color: #4a90bf;
        border-top-color: #67b7e5;
        box-shadow: 0 10px 26px rgba(0, 0, 0, 0.3);
    }

    & > .tgb-head {
        background: rgba(0, 0, 0, 0.22);
        border-bottom: 1px solid #38495a;
        ${tw`p-3`};
    }
`;

const TitledGreyBox = ({ icon, title, children, className }: Props) => (
    <Box className={className}>
        <div className={'tgb-head'}>
            {typeof title === 'string' ? (
                <p css={tw`text-xs uppercase tracking-wider text-gray-300`}>
                    {icon && <FontAwesomeIcon icon={icon} css={tw`mr-2`} style={{ color: '#67b7e5' }} />}
                    {title}
                </p>
            ) : (
                title
            )}
        </div>
        <div css={tw`p-3`}>{children}</div>
    </Box>
);

export default memo(TitledGreyBox, isEqual);
